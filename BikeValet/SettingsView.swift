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
    @Query private var parkingSlots: [CombinedZoneParkingSlot]
    @State private var isPresentingAlert: Bool = false
    @State private var isPresentingAddLot: Bool = false
    @State var slotSearchNumber = ""
    @State var newLotName = ""
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    var body: some View {
        NavigationStack {
            VStack {
                Text("App Version: \(appVersion ?? "0.0.0") build \(buildNumber ?? "0")")
                List {
                    if slotSearchNumber.isEmpty {
                        ForEach(parkingSlots) { slot in
                            HStack {
                                Text(slot.zoneName)
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
                                Text(slot.zoneName)
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
//                                try modelContext.delete(model: ParkingSlot.self)
                                try modelContext.delete(model: CombinedZoneParkingSlot.self)
                                dismiss()
                            } catch {
                                print("Failed to delete all.")
                            }
                      }
                    }
                    Spacer()
                    Button("Add another lot", systemImage: "document.badge.plus.fill", action: {
                        isPresentingAddLot = true
                    }).accentColor(.red)
                    .alert("What is the name of the new lot", isPresented: $isPresentingAddLot) {
                        TextField("New lot name", text: $newLotName)
                        Button("Add") {
                            modelContext.insert(ParkingLot(name: newLotName))
                            do {
                                try modelContext.save()
                                dismiss()
                            } catch {
                                print("Failed to delete all.")
                            }
                        }
                    }
                }.padding(20)
            }
            }.searchable(text: $slotSearchNumber, prompt: "Find by parking slot number")
    }
}

#Preview {
    SettingsView()
}
