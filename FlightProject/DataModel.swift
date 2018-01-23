//
//  DataModel.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/23/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import CoreData

class DataModel: NSManagedObject {
    @NSManaged var countries: Data
    @NSManaged var departureAirport: Data
    @NSManaged var destinationAirport: Data
}
