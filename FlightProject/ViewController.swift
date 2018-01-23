//
//  ViewController.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/20/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, AirportProtocol, CalendarProtocol {

    @IBOutlet weak var viewDepartureCity: UIView!
    @IBOutlet weak var labelDepartureCity: UILabel!
    
    @IBOutlet weak var viewDestinationCity: UIView!
    @IBOutlet weak var labelDestinationCity: UILabel!
    
    @IBOutlet weak var viewDepartureDate: UIView!
    @IBOutlet weak var labelDepartureDate: UILabel!
    
    @IBOutlet weak var viewPassenger: UIView!
    @IBOutlet weak var iconPassenger: UIImageView!
    @IBOutlet weak var labelTotalPassenger: UILabel!
    @IBOutlet weak var viewDetailPassenger: UIView!
    
    @IBOutlet weak var buttonAdultPlus: UIButton!
    @IBOutlet weak var buttonAdultMinus: UIButton!
    @IBOutlet weak var labelAdultPassenger: UILabel!
    
    @IBOutlet weak var buttonChildPlus: UIButton!
    @IBOutlet weak var buttonChildMinus: UIButton!
    @IBOutlet weak var labelChildPassenger: UILabel!
    
    @IBOutlet weak var buttonInfantPlus: UIButton!
    @IBOutlet weak var buttonInfantMinus: UIButton!
    @IBOutlet weak var labelInfantPassenger: UILabel!
    
    @IBOutlet weak var buttonSearch: UIButton!
    
    var departureAirport: Airport?
    var destinationAirport: Airport?
    var departureDate: String?
    
    var viewDepartureCityTapGesture = UITapGestureRecognizer()
    var viewDestinationCityTapGesture = UITapGestureRecognizer()
    var viewDepartureDateTapGesture = UITapGestureRecognizer()
    var viewPassengerTapGesture = UITapGestureRecognizer()
    
    var adult = 1
    var child = 0
    var infant = 0
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequestData = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentAirport")
        if let fetchResults = (try? managedObjectContext!.fetch(fetchRequestData)) as? [CurrentAirportModel] {
            if(fetchResults.count != 0) {
                do {
                    let data = fetchResults[0]
                    self.departureAirport = Airport(code: data.departureCode, name: data.departureName, location: data.departureLocation, countryId: data.departureCountryId)
                    self.destinationAirport = Airport(code: data.destinationCode, name: data.destinationName, location: data.destinationLocation, countryId: data.destinationCountryId)
                    self.labelDepartureCity.text = "\(self.departureAirport!.location) - \(self.departureAirport!.code)"
                    self.labelDepartureCity.textColor = UIColor.black
                    self.labelDestinationCity.text = "\(self.destinationAirport!.location) - \(self.destinationAirport!.code)"
                    self.labelDestinationCity.textColor = UIColor.black
                } catch _ as NSError {
                    
                } catch {
                    fatalError()
                }
            }
        }
        
        self.viewDepartureCityTapGesture.addTarget(self, action: #selector(self.viewCityFormClick(sender:)))
        self.viewDepartureCity.addGestureRecognizer(self.viewDepartureCityTapGesture)
        
        self.viewDestinationCityTapGesture.addTarget(self, action: #selector(self.viewCityFormClick(sender:)))
        self.viewDestinationCity.addGestureRecognizer(self.viewDestinationCityTapGesture)
        
        self.viewDepartureDateTapGesture.addTarget(self, action: #selector(self.viewDateFormClick(sender:)))
        self.viewDepartureDate.addGestureRecognizer(self.viewDepartureDateTapGesture)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        dateFormatter.locale = Locale(identifier: "id")
        let dateString = dateFormatter.string(from: NSDate() as Date)
        self.labelDepartureDate.text = dateString
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.departureDate = dateFormatter.string(from: NSDate() as Date)
        
        self.viewPassengerTapGesture.addTarget(self, action: #selector(ViewController.viewPassengerClick))
        self.viewPassenger.addGestureRecognizer(viewPassengerTapGesture)
        
        self.labelTotalPassenger.text = "\(adult+child+infant) Penumpang"
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flight" {
            let controller = segue.destination as! FlightListController
            controller.flightDescription = "\(String(describing: self.labelDepartureDate.text!)) | \(String(describing: self.labelTotalPassenger.text!))"
            controller.departureAirport = self.departureAirport
            controller.destinationAirport = self.destinationAirport
            controller.departureDate = self.departureDate
            controller.adult = self.adult
            controller.child = self.child
            controller.infant = self.infant
        }
    }
    
    @objc func viewCityFormClick(sender: AnyObject) {
        if let resultController = self.storyboard?.instantiateViewController(withIdentifier: "airport") as? AirportListController {
            if sender.view == self.viewDepartureCity {
                resultController.isDestination = false
            }
            else {
                resultController.isDestination = true
            }
            resultController.airportDelegate = self
            self.navigationController?.pushViewController(resultController, animated: true)
        }
    }
    
    func getSelectedAirport(airport: Airport, isDestination: Bool) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentAirport")
        if !isDestination {
            self.departureAirport = airport
            self.labelDepartureCity.text = "\(airport.location) - \(airport.code)"
            self.labelDepartureCity.textColor = UIColor.black
            
            if let fetchResults = (try? self.managedObjectContext!.fetch(fetchRequest)) as? [CurrentAirportModel] {
                if fetchResults.count == 0 {
                    let newItem = NSEntityDescription.insertNewObject(forEntityName: "CurrentAirport", into: self.managedObjectContext!) as! CurrentAirportModel
                    newItem.departureCode = airport.code
                    newItem.departureName = airport.name
                    newItem.departureLocation = airport.location
                    newItem.departureCountryId = airport.countryId
                }
                else {
                    let managedObject = fetchResults[0]
                    managedObject.setValue(airport.code, forKey: "departureCode")
                    managedObject.setValue(airport.name, forKey: "departureName")
                    managedObject.setValue(airport.location, forKey: "departureLocation")
                    managedObject.setValue(airport.countryId, forKey: "departureCountryId")
                }
                
                do {
                    try self.managedObjectContext!.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
        else {
            self.destinationAirport = airport
            self.labelDestinationCity.text = "\(airport.location) - \(airport.code)"
            self.labelDestinationCity.textColor = UIColor.black
            
            if let fetchResults = (try? self.managedObjectContext!.fetch(fetchRequest)) as? [CurrentAirportModel] {
                if fetchResults.count == 0 {
                    let newItem = NSEntityDescription.insertNewObject(forEntityName: "CurrentAirport", into: self.managedObjectContext!) as! CurrentAirportModel
                    newItem.destinationCode = airport.code
                    newItem.destinationName = airport.name
                    newItem.destinationLocation = airport.location
                    newItem.destinationCountryId = airport.countryId
                }
                else {
                    let managedObject = fetchResults[0]
                    managedObject.setValue(airport.code, forKey: "destinationCode")
                    managedObject.setValue(airport.name, forKey: "destinationName")
                    managedObject.setValue(airport.location, forKey: "destinationLocation")
                    managedObject.setValue(airport.countryId, forKey: "destinationCountryId")
                }
            }
            
            do {
                try self.managedObjectContext!.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    @IBAction func swapAirport(_ sender: Any) {
        let swap = self.departureAirport
        self.departureAirport = self.destinationAirport
        self.destinationAirport = swap
        
        self.labelDepartureCity.text = "\(self.departureAirport!.location) - \(self.departureAirport!.code)"
        self.labelDestinationCity.text = "\(self.destinationAirport!.location) - \(self.destinationAirport!.code)"
    }
    
    @objc func viewDateFormClick(sender: AnyObject) {
        if let resultController = storyboard?.instantiateViewController(withIdentifier: "calendar") as? CalendarViewController {
            resultController.calendarDelegate = self
            var currentSelectedDate: NSDate?
            if(labelDepartureDate.text == "") {
                currentSelectedDate = nil
            }
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, d MMM yyyy"
                dateFormatter.locale = Locale(identifier: "id")
                let str = labelDepartureDate.text
                currentSelectedDate = dateFormatter.date(from: str!) as! NSDate
            }
            resultController.currentSelectedDate = currentSelectedDate
            
            self.navigationController?.pushViewController(resultController, animated: true)
        }
    }
    
    func getSelectedDate(selectedDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        dateFormatter.locale = Locale(identifier: "id")
        
        let dateString = dateFormatter.string(from: selectedDate)
        self.labelDepartureDate.text = dateString
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.departureDate = dateFormatter.string(from: selectedDate)
    }

    @objc func viewPassengerClick() {
        if(viewDetailPassenger.isHidden) {
            viewDetailPassenger.isHidden = false
            //buttonSearchBottom.constant = 150
            //delegate?.detailPassengerOpen()
        }
        else {
            viewDetailPassenger.isHidden = true
            //buttonSearchBottom.constant = 40
            //delegate?.detailPassengerClose()
        }
    }
    
    @IBAction func adultPassenger(_ sender: Any) {
        let button = sender as! UIButton
        if(button.titleLabel?.text == "+") {
            adult += 1
            if(adult >= 2 && !buttonAdultMinus.isEnabled) {
                buttonAdultMinus.isEnabled = true
                buttonAdultMinus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
            if((adult + child) == 7) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
                buttonChildPlus.isEnabled = false
                buttonChildPlus.backgroundColor = UIColor.lightGray
            }
            if(adult > infant && !buttonInfantPlus.isEnabled) {
                buttonInfantPlus.isEnabled = true
                buttonInfantPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
        }
        else if(button.titleLabel?.text == "-") {
            adult -= 1
            if(adult == 1) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
            }
            if((adult + child) < 7 && !buttonAdultPlus.isEnabled && !buttonChildPlus.isEnabled) {
                buttonAdultPlus.isEnabled = true
                buttonAdultPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
                buttonChildPlus.isEnabled = true
                buttonChildPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
            if(adult < infant) {
                infant = adult
                labelInfantPassenger.text = "\(infant)"
            }
        }
        labelAdultPassenger.text = "\(adult)"
        labelTotalPassenger.text = "\(adult+child+infant) Penumpang"
        
        //delegate?.sendPassengerValue(adult, child: child, infant: infant)
    }
    
    @IBAction func childPassenger(_ sender: Any) {
        let button = sender as! UIButton
        if(button.titleLabel?.text == "+") {
            child += 1
            if(child >= 1 && !buttonChildMinus.isEnabled) {
                buttonChildMinus.isEnabled = true
                buttonChildMinus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
            if((adult + child) == 7) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
                buttonAdultPlus.isEnabled = false
                buttonAdultPlus.backgroundColor = UIColor.lightGray
            }
        }
        else if(button.titleLabel?.text == "-") {
            child -= 1
            if(child == 0) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
            }
            if((adult + child) < 7 && !buttonAdultPlus.isEnabled && !buttonChildPlus.isEnabled) {
                buttonAdultPlus.isEnabled = true
                buttonAdultPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
                buttonChildPlus.isEnabled = true
                buttonChildPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
        }
        labelChildPassenger.text = "\(child)"
        labelTotalPassenger.text = "\(adult+child+infant) Penumpang"
        
        //delegate?.sendPassengerValue(adult, child: child, infant: infant)
    }
    
    @IBAction func infantPassenger(_ sender: Any) {
        let button = sender as! UIButton
        if(button.titleLabel?.text == "+") {
            infant += 1
            if(infant >= 1 && !buttonInfantMinus.isEnabled) {
                buttonInfantMinus.isEnabled = true
                buttonInfantMinus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
            if(infant == adult) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
            }
        }
        else if(button.titleLabel?.text == "-") {
            infant -= 1
            if(infant == 0) {
                button.isEnabled = false
                button.backgroundColor = UIColor.lightGray
            }
            if(infant < adult && !buttonInfantPlus.isEnabled) {
                buttonInfantPlus.isEnabled = true
                buttonInfantPlus.backgroundColor = UIColor(red: 0.0663841, green: 0.373358, blue: 0.528939, alpha: 1.0)
            }
        }
        labelInfantPassenger.text = "\(infant)"
        labelTotalPassenger.text = "\(adult+child+infant) Penumpang"
        
        //delegate?.sendPassengerValue(adult, child: child, infant: infant)
    }

}

