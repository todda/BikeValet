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
    @FocusState private var focusConfirm: Bool
    @State private var occupiedSlot: ParkingSlot? = nil

    var body: some View {
        if let mainLot = parkingLots.first {
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
                            .focused($focusConfirm)
                            .textSelection(.disabled)
                            .background(Color.accent)
                            .font(.system(size: 26))
                            .onAppear() {
                                focusConfirm = true
                            }
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
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print ("oh no")
                                    }
                                }
                                cardNumber = ""
                                focusConfirm = true
                            }
                        GeometryReader { cell in
                            VStack {
                                HStack {
                                    Text("State").font(.system(size: 26))
                                        .foregroundStyle(.gray)
                                        .frame(width: cell.size.width * 0.2)
                                    Text("Lot").font(.system(size: 26))
                                        .foregroundStyle(.gray)
                                        .frame(width: cell.size.width * 0.4)
                                    Text("Bay Number").font(.system(size: 26))
                                        .foregroundStyle(.gray)
                                        .frame(width: cell.size.width * 0.4)
                                }
                                HStack {
                                    Text("\(checkedIn ? "Out" : "In")").font(.system(size: 26))
                                        .frame(width: cell.size.width * 0.2)
                                    Text("\(occupiedSlot?.lot?.lotName ?? "none")").font(.system(size: 26))
                                        .frame(width: cell.size.width * 0.4)
                                    Text("\(value: occupiedSlot?.bayNumber ?? 0)").font(.system(size: 96))
                                        .frame(width: cell.size.width * 0.4)
                                }
                            }.border(.gray)
                        }
                    }.padding(100)
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
