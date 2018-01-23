//
//  MainController.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/23/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class MainController: UIViewController {
    
    var countries = [Country]()
    var isAppear = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let secretKey = "865efba03fd9fa92105b5e467bf28e05"
        if !isAppear {
            if appDelegate.token == nil {
                Alamofire.request(
                    "https://api-sandbox.tiket.com/apiv1/payexpress?method=getToken&secretkey=\(secretKey)&output=json",
                    method: .get
                    )
                    .responseJSON { response in
                        let result = (response.result.value as? [String : Any])!
                        let diagnostic = (result["diagnostic"] as? [String : Any])!
                        if let errorMessage = diagnostic["error_msgs"] as? String {
                            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { UIAlertAction in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.appDelegate.token = result["token"] as? String
                            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Security", into: self.managedObjectContext!) as! SecurityModel
                            newItem.token = self.appDelegate.token!
                            do {
                                try self.managedObjectContext!.save()
                            } catch {
                                let nserror = error as NSError
                                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                                abort()
                            }
                            
                            self.getCountry(token: self.appDelegate.token!, isUpdate: false)
                        }
                }
            }
            else {
                var isUpdate = false
                let fetchRequestData = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
                if let fetchResults = (try? managedObjectContext!.fetch(fetchRequestData)) as? [CountryModel] {
                    if(fetchResults.count != 0) {
                        var arrayCountries = [Country]()
                        do {
                            for result in fetchResults {
                                let newCountry = Country(id: result.id, name: result.name, areaCode: result.areaCode)
                                if(newCountry.id == "id") {
                                    arrayCountries.insert(newCountry, at: 0)
                                }
                                else {
                                    arrayCountries.append(newCountry)
                                }
                            }
                            appDelegate.countries = arrayCountries
                            let navigation = self.storyboard?.instantiateViewController(withIdentifier: "navigation") as! UINavigationController
                            self.present(navigation, animated: true, completion: nil)
                            isUpdate = true
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
                            arrayCountries = [Country]()
                        } catch {
                            fatalError()
                        }
                    }
                }
                getCountry(token: self.appDelegate.token!, isUpdate: isUpdate)
            }
            
            isAppear = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCountry(token: String, isUpdate: Bool) {
        Alamofire.request(
            "https://api-sandbox.tiket.com/general_api/listCountry?token=\(token)&output=json",
            method: .get
            )
            .responseJSON { response in
                let result = (response.result.value as? [String : Any])!
                let diagnostic = (result["diagnostic"] as? [String : Any])!
                if let errorMessage = diagnostic["error_msgs"] as? String {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let listCountry = (response.result.value as? [String : Any])!["listCountry"] as! NSArray
                    for country in listCountry {
                        let ctry = country as! [String:AnyObject]
                        let newCountry = Country(id: ctry["country_id"] as! String, name: ctry["country_name"] as! String, areaCode: ctry["country_areacode"] as! String)
                        if(newCountry.id == "id") {
                            self.countries.insert(newCountry, at: 0)
                        }
                        else {
                            self.countries.append(newCountry)
                        }
                        
                        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Country", into: self.managedObjectContext!) as! CountryModel
                        newItem.areaCode = newCountry.areaCode
                        newItem.id = newCountry.id
                        newItem.name = newCountry.name
                        
                        do {
                            try self.managedObjectContext!.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                            abort()
                        }
                    }
                    self.appDelegate.countries = self.countries
                    
                    if(!isUpdate) {
                        let navigation = self.storyboard?.instantiateViewController(withIdentifier: "navigation") as! UINavigationController
                        self.present(navigation, animated: true, completion: nil)
                    }
                }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
