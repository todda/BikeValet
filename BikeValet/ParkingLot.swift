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
    @Relationship(deleteRule: .cascade, inverse: \CombinedZoneParkingSlot.lot)
    var lotName: String = "Unknown Lot"
    var slots: [CombinedZoneParkingSlot]? = []
    var isExpanded: Bool = true

    func highestOccupiedSlot() -> Int {
        var returnBayNumber = 0

        guard let slots else { return returnBayNumber }

        for i in 0..<slots.count {
            if slots[i].bayNumber > returnBayNumber {
                returnBayNumber = slots[i].bayNumber
            }
        }
        return returnBayNumber
    }

    func moveZone(from: String, to: String) -> Void {
        guard let slots else { return }
        print("\(slots.count) items in lot")
        for slot in slots where slot.zoneName == from {
            print("moving zone from: \(slot.zoneName) to: \(to)")
            slot.zoneName = to
        }
    }

    func nextBestOccupiedSlot() -> Int {
        var bestBayNumber = 1

        guard let slots else { return bestBayNumber }

        for _ in 0..<slots.count {
            if slots.contains(where: { $0.bayNumber == bestBayNumber}) {
                bestBayNumber = bestBayNumber + 1
            }
        }
        return bestBayNumber
    }

    init(name: String, slots: [CombinedZoneParkingSlot] = []) {
        self.lotName = name
        self.slots = slots
    }
}

@Model
final class CombinedZoneParkingSlot {
    @Relationship(inverse: \ParkingLot.slots)
    var lot: ParkingLot? = nil
    var zoneName: String = "Unknown Zone"
    var timestamp: Date = Date.now
    var badgeId: String = "Unknown Badge"
    var bayNumber: Int = 0

    init(badgeId: String, bayNumber: Int = 0, lot: ParkingLot, zone: String = "") {
        self.timestamp = Date.now
        self.lot = lot
        self.zoneName = zone
        if (true) {
            self.bayNumber = (bayNumber == 0) ? lot.highestOccupiedSlot() + 1 : bayNumber
        } else {
            self.bayNumber = (bayNumber == 0) ? lot.nextBestOccupiedSlot() : bayNumber
        }
        self.badgeId = badgeId
    }
}

@Model
final class ParkingSlot {
    //@Relationship(deleteRule: .cascade, inverse: \ParkingLot.slots)
    var lot: ParkingLot?
    var timestamp: Date
    var badgeId: String
    var bayNumber: Int

    init(badgeId: String, bayNumber: Int = 0, lot: ParkingLot) {
        self.timestamp = Date.now
        self.lot = lot
        if (true) {
            self.bayNumber = (bayNumber == 0) ? lot.highestOccupiedSlot() + 1 : bayNumber
        } else {
            self.bayNumber = (bayNumber == 0) ? lot.nextBestOccupiedSlot() : bayNumber
        }
        self.badgeId = badgeId
    }
}
