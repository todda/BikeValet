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
    //@Relationship(deleteRule: .cascade, inverse: \ParkingSlot.lot)
    var lotName: String
    var slots: [ParkingSlot]

    init(name: String, slots: [ParkingSlot] = []) {
        self.lotName = name
        self.slots = slots
    }
}

@Model
final class ParkingSlot {
    @Relationship(deleteRule: .cascade, inverse: \ParkingLot.slots)

    var lot: ParkingLot?
    var timestamp: Date
    var badgeId: String
    var bayNumber: Int

    init(badgeId: String, lot: ParkingLot) {
        self.timestamp = Date.now
        self.lot = lot
        self.bayNumber = lot.slots.count + 1
        self.badgeId = badgeId
    }
}
