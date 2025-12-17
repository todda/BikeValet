//
//  SettingsView.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/20/25.
//

import SwiftUI
import SwiftData
internal import Combine

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var parkingSlots: [ParkingSlot]
    @State private var isPresentingAlert: Bool = false
    @State var slotSearchNumber = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if slotSearchNumber.isEmpty {
                        ForEach(parkingSlots) { slot in
                            HStack {
                                Text(slot.lot.lotName)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Spacer()
                                        Text(slot.badgeId)
                                    }.containerRelativeFrame(.horizontal, alignment: .trailing)
                                }
                                Text("\(value: slot.bayNumber)")
                                NavigationLink(destination: EditParkedItem(oldSlot: slot)) {
                                }
                            }
                        }
                    } else {
                        ForEach(parkingSlots.filter { slot in slot.bayNumber == Int(slotSearchNumber)}) { slot in
                            HStack {
                                Text(slot.lot.lotName)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Spacer()
                                        Text(slot.badgeId)
                                    }.containerRelativeFrame(.horizontal, alignment: .trailing)
                                }
                                Text("\(value: slot.bayNumber)")
                                NavigationLink(destination: EditParkedItem(oldSlot: slot))  {
                                }
                            }
                        }
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
            }.searchable(text: $slotSearchNumber, prompt: "Find by parking slot number")
    }
}

#Preview {
    SettingsView()
}
