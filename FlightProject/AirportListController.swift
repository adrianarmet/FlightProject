//
//  AirportListController.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/21/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

protocol AirportProtocol {
    func getSelectedAirport(airport: Airport, isDestination: Bool)
}

class AirportListController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    var countries = [Country]()
    var airports = [String : [Airport]]()
    var allAirport = [Airport]()
    var isDestination: Bool?
    var airportDelegate: AirportProtocol?
    var resultSearchController = UISearchController()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isDestination! {
            self.navigationItem.title = "Pilih Bandara Keberangkatan"
        }
        else {
            self.navigationItem.title = "Pilih Bandara Tujuan"
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.countries = appDelegate.countries
        for country in countries {
            self.airports[country.id] = [Airport]()
        }
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            
            self.definesPresentationContext = true
            
            return controller
        })()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let fetchRequestData = NSFetchRequest<NSFetchRequestResult>(entityName: "Airport")
        if let fetchResults = (try? managedObjectContext!.fetch(fetchRequestData)) as? [AirportModel] {
            if fetchResults.count != 0 {
                var arrayAirports = [String : [Airport]]()
                var arrayAllAirport = [Airport]()
                for country in countries {
                    arrayAirports[country.id] = [Airport]()
                }
                do {
                    for result in fetchResults {
                        let newAirport = Airport(code: result.code, name: result.name, location: result.location, countryId: result.countryId)
                        arrayAirports[newAirport.countryId]?.append(newAirport)
                        arrayAllAirport.append(newAirport)
                    }
                    
                    self.airports = arrayAirports
                    self.allAirport = arrayAllAirport
                    self.tableView.reloadData()
                    
                    for fetchResult in fetchResults {
                        managedObjectContext?.delete(fetchResult)
                    }
                    //////save to core data/////////
                    do {
                        try self.managedObjectContext!.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                } catch _ as NSError {
                    
                } catch {
                    fatalError()
                }
            }
        }
        getAirport(token: appDelegate.token!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAirport(token: String) {
        Alamofire.request(
            "https://api-sandbox.tiket.com/flight_api/all_airport?token=\(token)&output=json",
            method: .get
            )
            .responseJSON{ response in
                var arrayAirports = [String : [Airport]]()
                var arrayAllAirport = [Airport]()
                for country in self.countries {
                    arrayAirports[country.id] = [Airport]()
                }
                let allAirport = (response.result.value as? [String : Any])!["all_airport"] as! [String : Any]
                let listAirport = allAirport["airport"] as! NSArray
                for airport in listAirport {
                    let ap = airport as! [String : AnyObject]
                    let countryId = ap["country_id"] as! String
                    let newAirport = Airport(code: ap["airport_code"] as! String, name: ap["airport_name"] as! String, location: ap["location_name"] as! String, countryId: countryId)
                    arrayAirports[countryId]?.append(newAirport)
                    arrayAllAirport.append(newAirport)
                    
                    let newItem = NSEntityDescription.insertNewObject(forEntityName: "Airport", into: self.managedObjectContext!) as! AirportModel
                    newItem.code = newAirport.code
                    newItem.location = newAirport.location
                    newItem.name = newAirport.name
                    newItem.countryId = newAirport.countryId
                    
                    do {
                        try self.managedObjectContext!.save()
                    } catch {
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
                
                self.airports = arrayAirports
                self.allAirport = arrayAllAirport
                self.tableView.reloadData()
        }
    }
    
    var filteredContent = [Airport]()
    func filterContentForSearchText(_ searchText: String) {
        self.filteredContent = self.allAirport.filter({(airportFilter: Airport) -> Bool in
            var stringMatch = airportFilter.name.lowercased().range(of: searchText.lowercased())
            if(stringMatch == nil) {
                stringMatch = airportFilter.location.lowercased().range(of: searchText.lowercased())
            }
            return (stringMatch != nil)
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContent.removeAll(keepingCapacity: false)
        
        self.filterContentForSearchText(searchController.searchBar.text!)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.resultSearchController.searchBar.text != "" {
            return 1
        }
        return self.countries.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.resultSearchController.searchBar.text != "" {
            return 0
        }
        else if (self.airports[self.countries[section].id]?.count)! > 0 {
            return 25
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.resultSearchController.searchBar.text != "" {
            return self.filteredContent.count
        }
        return (self.airports[self.countries[section].id]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 25))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.text = self.countries[section].name
        
        view.addSubview(label)
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var airport: Airport
        if self.resultSearchController.searchBar.text != "" {
            airport = self.filteredContent[indexPath.row]
        }
        else {
            airport = self.airports[self.countries[indexPath.section].id]![indexPath.row]
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.text = "\(airport.location) (\(airport.code)) | \(airport.name)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var airport: Airport
        if self.resultSearchController.searchBar.text != "" {
            airport = self.filteredContent[indexPath.row]
        }
        else {
            airport = self.airports[self.countries[indexPath.section].id]![indexPath.row]
        }
        self.airportDelegate?.getSelectedAirport(airport: airport, isDestination: self.isDestination!)
        self.navigationController?.popToRootViewController(animated: true)
    }

}
