//
//  SettingsView.swift
//  BikeValet
//
//  Created on 11/20/25.
//

import SwiftUI
import SwiftData
internal import Combine

struct SimpleCheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
        }
        .buttonStyle(.plain)
    }
}
    
struct SelectedItem: Identifiable {
    let id = UUID()
    var selected = false
}

struct SettingsView: View {
    static let MAX_ZONES = 1000
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var parkingLots: [ParkingLot]
    @State private var isPresentingAlert: Bool = false
    @State private var isPresentingAddLot: Bool = false
    @State private var isPresentingEditLot: Bool = false
    @State private var isPresentingVerify: Bool = false
    @State var slotSearchNumber = ""
    @State var newLotName = ""
    @State var selectedLotId: Int = MAX_ZONES
    @State private var selectedItems : [SelectedItem] = Array(repeating: SelectedItem(), count: 1000)
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    @State var verifyIds = "all badge ids are unique..."
    @State var verifyContiguousSlots = "all parking slots are contiguous..."
    @State var verifyUniqueSlots = "all badge ids are unique..."
    @State var uniqueIds: [String] = []
    @State var uniqueBay: [Int] = []

    var body: some View {
        let mainLot = parkingLots.firstIndex(where: { ($0.slots!.count > 0 || $0.lotName == "Main") })!

        NavigationStack {
            VStack {
                Text("App Version: \(appVersion ?? "0.0.0") build \(buildNumber ?? "0")")

                HStack {
                    Picker(selection: $selectedLotId, label: Text("Current Lot:")) {
                        Text("All").tag(SettingsView.MAX_ZONES)
                        ForEach(0 ..< parkingLots.count, id: \.self) {
                            Text(parkingLots[$0].lotName)
                        }
                    }.pickerStyle(.segmented)
                }.padding(10)

                List() {
                    if slotSearchNumber.isEmpty {
                        let filteredArray = Array(parkingLots[mainLot].slots!.filter {
                            filterSlot in (selectedLotId == SettingsView.MAX_ZONES ? !filterSlot.zoneName.isEmpty : filterSlot.zoneName == parkingLots[selectedLotId].lotName)}).sorted { $0.bayNumber < $1.bayNumber }
                        Toggle(sources: $selectedItems, isOn: \.selected) {Text("Check all")}.toggleStyle(SimpleCheckToggleStyle())
                        ForEach(filteredArray.indices, id: \.self) { index in
                            let slot = filteredArray[index]
                            HStack {
                                Toggle("", isOn: $selectedItems[index].selected).toggleStyle(SimpleCheckToggleStyle())
                                Text(slot.zoneName)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Spacer()
                                        Text(slot.badgeId)
                                    }.containerRelativeFrame(.horizontal, alignment: .trailing)
                                }
                                Text("\(value: slot.bayNumber)")
                                let selectedSlots = filteredArray.enumerated().filter { (index, _) in
                                    return selectedItems[index].selected == true
                                }.map { $0.element }

                                if (selectedSlots.count > 1) {
                                    NavigationLink(destination: EditMultipleParkedItem(oldSlots: selectedSlots)) {}
                                } else {
                                    NavigationLink(destination: EditParkedItem(oldSlot: slot)) {}
                                }
                            }
                        }
                    } else {
                        let filteredArray = Array(parkingLots[mainLot].slots!.filter {
                            filterSlot in (filterSlot.bayNumber == Int(slotSearchNumber))})
                        ForEach(filteredArray.indices, id: \.self) { index in
                            let slot = filteredArray[index]
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
                .searchable(text: $slotSearchNumber, prompt: "Find parking slot")

                HStack {
                    Button("Delete all", systemImage: "trash.fill", action: {
                        isPresentingAlert = true
                    }).accentColor(.red)
                    .confirmationDialog("Are you sure you want to remove all checked in bicycles?",
                        isPresented: $isPresentingAlert) {
                        Button("Yes, delete all", role: .destructive) {
                            do {
                                try modelContext.delete(model: CombinedZoneParkingSlot.self)
                                try modelContext.save()
                            } catch {
                                print("Failed to delete all.")
                            }
                            dismiss()
                      }
                    }
                    Spacer()
                    Button("Verify", systemImage: "bolt.heart", action: {
                        for bayIndex in 1..<parkingLots[mainLot].slots!.count {
                            if !parkingLots[mainLot].slots!.contains(where: { $0.bayNumber == bayIndex }) {
                                verifyContiguousSlots += "bay: \(bayIndex) is missing\n"
                            }
                        }
                        for (index, slot) in parkingLots[mainLot].slots!.enumerated() {
                            if (nil == parkingLots[mainLot].slots![index]) {
                                verifyContiguousSlots += "index: \(index) is missing\n"
                            }
                            if uniqueIds.contains(slot.badgeId) {
                                verifyUniqueSlots += "id: \(slot.badgeId) occurs more than once.  Last bay: \(slot.bayNumber)\n"
                            } else {
                                uniqueIds.append(slot.badgeId)
                            }
                            if uniqueBay.contains(slot.bayNumber) {
                                verifyUniqueSlots += "bay: \(slot.bayNumber) occurs more than once\n"
                            } else {
                                uniqueBay.append(slot.bayNumber)
                            }
                        }
                        uniqueIds.removeAll()
                        uniqueBay.removeAll()
                        
                        isPresentingVerify = true
                    }).accentColor(.blue)
                        .alert("Verifying Integrity...", isPresented: $isPresentingVerify, actions: {
                        }, message: {
                            Text("\(verifyIds)\n\(verifyUniqueSlots)\n\(verifyContiguousSlots)")
                        })
                    Spacer()
                    if (selectedLotId != SettingsView.MAX_ZONES) {
                        Text("Lot: \(parkingLots[selectedLotId].lotName)")
                        NavigationLink(destination: EditLotName(oldLot: parkingLots[selectedLotId]), label: {
                            Text("Rename")
                        })
                        Spacer()
                    }
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
                                print("Failed to save added lot.")
                            }
                        }
                    }
                }.padding(20)
            }
        }.onAppear() {
            for index in selectedItems.indices {
                selectedItems[index].selected = false
            }
        }
    }
}

#Preview {
    SettingsView()
}
