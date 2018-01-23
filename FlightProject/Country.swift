//
//  Country.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/22/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import CoreData

struct Country {
    var id: String
    var name: String
    var areaCode: String
}

class CountryModel: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var areaCode: String
}
