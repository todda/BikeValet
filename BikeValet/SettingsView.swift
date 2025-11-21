//
//  SettingsView.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/20/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var parkingSlots: [ParkingSlot]

    var body: some View {
        NavigationStack {
            VStack {
                List(parkingSlots) { slot in
                    HStack {
                        Text(slot.lot.lotName)
                        Text(slot.badgeId)
                        Text("\(value: slot.bayNumber)")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
