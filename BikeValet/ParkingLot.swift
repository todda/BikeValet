//
//  Item.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/10/25.
//

import Foundation
import SwiftData

@Model
final class ParkingLot {
    var lotName: String
    @Relationship(deleteRule: .cascade, inverse: \ParkingSlot.lot) var slots: [ParkingSlot]

    init(name: String, slots: [ParkingSlot] = []) {
        self.lotName = name
        self.slots = slots
    }
}

@Model
final class ParkingSlot {
    var timestamp: Date
    var badgeId: String
    var lot: ParkingLot
    var bayNumber: Int

    init(badgeId: String, lot: ParkingLot) {
        self.timestamp = Date.now
        self.lot = lot
        self.bayNumber = 0
        self.badgeId = badgeId
    }
}
