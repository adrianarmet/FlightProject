//
//  FlightListController.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/23/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class FlightTableViewCell: UITableViewCell {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var stop: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var airlinesName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class FlightListController: UIViewController, UITableViewDelegate, UITableViewDataSource, SortProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelDescription: UILabel!
    
    var flightDescription: String?
    var departureAirport: Airport?
    var destinationAirport: Airport?
    var departureDate: String?
    var adult: Int?
    var child: Int?
    var infant: Int?
    var flights = [Flight]()
    var sortIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\((self.departureAirport?.location)!) (\((self.departureAirport?.code)!)) - \((self.destinationAirport?.location)!) (\((self.destinationAirport?.code)!))"
        self.labelDescription.text = self.flightDescription
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let url = "http://api-sandbox.tiket.com/search/flight?d=\((self.departureAirport?.code)!)&a=\((self.destinationAirport?.code)!)&date=\(self.departureDate!)&adult=\(self.adult!)&child=\(self.child!)&infant=\(self.infant!)&token=0264f5a287855c893d68eb16a5a5e3761cef5e12&v=3&output=json"
        
        Alamofire.request(
            url,
            method: .get
            )
            .responseJSON{ response in
                let departures = (response.result.value as? [String : Any])!["departures"] as! [String : Any]
                let listFlight = departures["result"] as! NSArray
                for flight in listFlight {
                    let f = flight as! [String : AnyObject]
                    self.flights.append(Flight(airlinesName: f["airlines_name"] as! String, airlinesLogo: f["image"] as! String, departureTime: f["simple_departure_time"] as! String, arrivalTime: f["simple_arrival_time"] as! String, duration: f["duration"] as! String, stop: f["stop"] as! String, price: Double(f["price_value"] as! String)!))
                }
                self.sort(identifier: "lowest_price", index: self.sortIndex)
                self.tableView.reloadData()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flights.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flight_cell", for: indexPath) as! FlightTableViewCell
        
        let flight = self.flights[indexPath.row]
        cell.time.text = "\(flight.departureTime) - \(flight.arrivalTime)"
        cell.duration.text = flight.duration
        cell.stop.text = flight.stop
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        let formattedString = numberFormatter.string(from: NSNumber(value: flight.price))
        cell.price.text = "IDR \(formattedString!)"
        cell.icon.kf.setImage(with: URL(string: flight.airlinesLogo))
        cell.airlinesName.text = flight.airlinesName.capitalized
        
        return cell
    }
    
    func sort(identifier: String, index: Int) {
        self.sortIndex = index
        switch identifier {
            case "lowest_price":
                self.flights.sort(by: { $0.price < $1.price })
                self.tableView.reloadData()
            case "earliest_departure":
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                outFormatter.dateFormat = "HH:mm"
            
                self.flights.sort(by: { outFormatter.string(from: inFormatter.date(from: $0.departureTime)!) < outFormatter.string(from: inFormatter.date(from: $1.departureTime)!) })
                self.tableView.reloadData()
            case "latest_departure":
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                outFormatter.dateFormat = "HH:mm"
                
                self.flights.sort(by: { outFormatter.string(from: inFormatter.date(from: $0.departureTime)!) > outFormatter.string(from: inFormatter.date(from: $1.departureTime)!) })
                self.tableView.reloadData()
            case "earliest_arrival":
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                outFormatter.dateFormat = "HH:mm"
                
                self.flights.sort(by: { outFormatter.string(from: inFormatter.date(from: $0.arrivalTime)!) < outFormatter.string(from: inFormatter.date(from: $1.arrivalTime)!) })
                self.tableView.reloadData()
            case "latest_arrival":
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                outFormatter.dateFormat = "HH:mm"
                
                self.flights.sort(by: { outFormatter.string(from: inFormatter.date(from: $0.arrivalTime)!) > outFormatter.string(from: inFormatter.date(from: $1.arrivalTime)!) })
                self.tableView.reloadData()
            case "shortest_duration":
                self.flights.sort(by: { duration(durationString: $0.duration) < duration(durationString: $1.duration) })
                self.tableView.reloadData()
            default:
                break
        }
    }
    
    func duration(durationString: String) -> Int {
        let h = 60
        let splitDuration = durationString.components(separatedBy: " ")
        
        return ((Int(splitDuration[0]))! * h) + (Int(splitDuration[2]))!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sort" {
            let controller = segue.destination as! SortFlightController
            controller.delegate = self
            controller.index = self.sortIndex
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
