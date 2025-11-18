//
//  Item.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
