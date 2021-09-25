//
//  ParkingSpotData.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 11..
//

import Foundation

class ParkingSpotData {
    
    let address: String
    let details: String
    let date: Date
    let rawLocation: String
    
    init(address: String, details: String, date: Date, rawLocation: String) {
        self.address = address
        self.details = details
        self.date = date
        self.rawLocation = rawLocation
    }
    
}
