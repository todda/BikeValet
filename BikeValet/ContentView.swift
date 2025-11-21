//
//  ContentView.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var parkingLots: [ParkingLot]
    @Query private var parkingSlots: [ParkingSlot]

    @State private var cardNumber: String = ""
    @State private var checkedIn: Bool = false
    @State private var editItemPressed = false
    @State private var settingsPressed = false
    @State private var occupiedSlot: ParkingSlot? = nil

    func create() {
        let mainLot = ParkingLot(name: "Main")
        let slot = ParkingSlot(badgeId: "123", lot: mainLot)
        
        modelContext.insert(mainLot)
        modelContext.insert(slot)

        //try? modelContext.save()
    }

    var body: some View {
        let mainLot = parkingLots[0]
        NavigationStack {
            VStack {
                HStack {
                    Text("Current Checkins: \(value: mainLot.slots.count)")
                    Spacer()
                    Button("", systemImage: "gearshape.fill", action: {
                    })
                }.padding(100)
                Spacer()
                VStack {
                    TextField("333", text: $cardNumber)
                        .font(.system(size: 26))
                        .multilineTextAlignment(.center).onSubmit {
                            occupiedSlot = parkingSlots.first(where: { $0.badgeId == cardNumber })
                            if ((occupiedSlot) != nil) {
                                checkedIn = true
                                modelContext.delete(occupiedSlot!)
                                mainLot.slots.removeAll(where: { $0.badgeId == cardNumber })
                            } else {
                                checkedIn = false
                                occupiedSlot = ParkingSlot(badgeId: cardNumber, lot: mainLot)
                                modelContext.insert(occupiedSlot!)
                                mainLot.slots.append(occupiedSlot!)
                                try? modelContext.save()
                            }
                        }
                    Text("\(checkedIn ? "Checking Out" : "Checking In")").font(.system(size: 26))
                    Text("\(occupiedSlot?.lot.lotName ?? "") \(value: occupiedSlot?.bayNumber ?? 0)").font(.system(size: 96))
                }
                Spacer()
                HStack {
                    Text("Total Checkins: \(value: 3122)")
                    Spacer()
                    Button("", systemImage: "pencil", action: {
                        editItemPressed.toggle()
                    })
                    Button("", systemImage: "gearshape.fill", action: {
                        settingsPressed.toggle()
                    })
                }.padding(100)
            }
        }.sheet(isPresented: $editItemPressed, content: {
            EditParkedItem()
        })
        .sheet(isPresented: $settingsPressed, content: {
            SettingsView()
        })
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation(value: Int) {
        self.appendLiteral("\(value)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ParkingLot.self, inMemory: true)
}
