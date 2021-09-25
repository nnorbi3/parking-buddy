//
//  ParkingSpot+CoreDataProperties.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 11..
//
//

import Foundation
import CoreData


extension ParkingSpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParkingSpot> {
        return NSFetchRequest<ParkingSpot>(entityName: "ParkingSpot")
    }

    @NSManaged public var address: String?
    @NSManaged public var details: String?
    @NSManaged public var date: Date?
    @NSManaged public var rawLocation: String?

}

extension ParkingSpot : Identifiable {

}
