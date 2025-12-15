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
    @Relationship(deleteRule: .cascade, inverse: \ParkingSlot.lot)
    var lotName: String
    var slots: [ParkingSlot]

    func highestOccupiedSlot() -> Int {
        var returnBayNumber = 0

        for i in 0..<slots.count {
            if slots[i].bayNumber > returnBayNumber {
                returnBayNumber = slots[i].bayNumber
            }
        }
        return returnBayNumber
    }

    func nextBestOccupiedSlot() -> Int {
        var bestBayNumber = 1

        for _ in 0..<slots.count {
            if slots.contains(where: { $0.bayNumber == bestBayNumber}) {
                bestBayNumber = bestBayNumber + 1
            }
        }
        return bestBayNumber
    }

    init(name: String, slots: [ParkingSlot] = []) {
        self.lotName = name
        self.slots = slots
    }
}

@Model
final class ParkingSlot {
    //@Relationship(deleteRule: .cascade, inverse: \ParkingLot.slots)
    var lot: ParkingLot
    var timestamp: Date
    var badgeId: String
    var bayNumber: Int

    init(badgeId: String, bayNumber: Int = 0, lot: ParkingLot) {
        self.timestamp = Date.now
        self.lot = lot
        self.bayNumber = (bayNumber == 0) ? lot.highestOccupiedSlot() + 1 : bayNumber
//        self.bayNumber = (bayNumber == 0) ? lot.nextBestOccupiedSlot() : bayNumber
        self.badgeId = badgeId
    }
}
