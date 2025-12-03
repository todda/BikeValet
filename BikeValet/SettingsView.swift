//
//  SettingsView.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/20/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var parkingSlots: [ParkingSlot]
    @State private var isPresentingAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                List(parkingSlots) { slot in
                    HStack {
                        Text(slot.lot?.lotName ?? "unknown")
                        Text(slot.badgeId)
                        Text("\(value: slot.bayNumber)")
                        Button("Edit", systemImage: "pencil", action: {
                            //EditParkedItem()
                        })
                    }
                }
                HStack {
                    Button("Delete all", systemImage: "trash.fill", action: {
                        isPresentingAlert = true
                    }).accentColor(.red)
                    .confirmationDialog("Are you sure you want to remove all checked in bicycles?",
                        isPresented: $isPresentingAlert) {
                        Button("Yes, delete all", role: .destructive) {
                            do {
                                //try modelContext.delete(model: ParkingLot.self)
                                try modelContext.delete(model: ParkingSlot.self)
                                dismiss()
                            } catch {
                                print("Failed to delete all.")
                            }
                      }
                    }
                    Spacer()
                    Button("Add another lot") {
                        dismiss()
                    }
                }.padding(20)
            }
        }
    }
}

#Preview {
    SettingsView()
}
