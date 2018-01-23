//
//  Airport.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/23/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import CoreData

struct Airport {
    var code: String
    var name: String
    var location: String
    var countryId: String
}

class AirportModel: NSManagedObject {
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var location: String
    @NSManaged var countryId: String
}

class CurrentAirportModel: NSManagedObject {
    @NSManaged var departureCode: String
    @NSManaged var departureName: String
    @NSManaged var departureLocation: String
    @NSManaged var departureCountryId: String
    @NSManaged var destinationCode: String
    @NSManaged var destinationName: String
    @NSManaged var destinationLocation: String
    @NSManaged var destinationCountryId: String
}
