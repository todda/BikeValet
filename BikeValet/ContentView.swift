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

    @State private var selectedLotId: Int = 0
    @State private var cardNumber: String = ""
    @State private var lastCardNumber: String = ""
    @State private var checkedIn: Bool = false
    @State private var editItemPressed = false
    @State private var settingsPressed = false
    @FocusState private var focusConfirm: Bool
    @State private var occupiedSlot: ParkingSlot? = nil

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Current Checkins: \(value: parkingSlots.count)")
                    Spacer()
                    Button("", systemImage: "gearshape.fill", action: {
                    })
                }.padding(100)
                Spacer()
                HStack {
                    Picker(selection: $selectedLotId, label: Text("Current Lot:")) {
                        ForEach(0 ..< parkingLots.count, id: \.self) {
                            Text(parkingLots[$0].lotName)
                        }
                    }.pickerStyle(.segmented)
                }.padding(100)
                VStack {
                    TextField("Waiting for card scan", text: $cardNumber)
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
                            } else {
                                checkedIn = false
                                occupiedSlot = ParkingSlot(badgeId: cardNumber, lot: parkingLots[selectedLotId])
                                modelContext.insert(occupiedSlot!)
                                do {
                                    try modelContext.save()
                                } catch {
                                    print ("oh no")
                                }
                            }
                            lastCardNumber = cardNumber
                            cardNumber = ""
                            focusConfirm = true
                        }
                    Text("Last card scanned: \(lastCardNumber)")
                    GeometryReader { cell in
//                            HStack {
//                                Text("State").font(.system(size: 26))
//                                    .foregroundStyle(.gray)
//                                    .frame(width: cell.size.width * 0.2)
//                                Text("Lot").font(.system(size: 26))
//                                    .foregroundStyle(.gray)
//                                    .frame(width: cell.size.width * 0.4)
//                                Text("Bay Number").font(.system(size: 26))
//                                    .foregroundStyle(.gray)
//                                    .frame(width: cell.size.width * 0.4)
//                            }.frame(height: cell.size.height * 0.1)
                        HStack {
                            Text("\(checkedIn ? "Out" : "In")").font(.system(size: 26))
                                .frame(width: cell.size.width * 0.2)
                            Text("\(occupiedSlot?.lot.lotName ?? "Unknown Lot")").font(.system(size: 26))
                                .frame(width: cell.size.width * 0.4)
                            Text("\(value: occupiedSlot?.bayNumber ?? 0)").font(.system(size: 96))
                                .frame(width: cell.size.width * 0.4)
                        }.frame(height: cell.size.height * 0.9)
                        Spacer()
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

extension DefaultStringInterpolation {
    mutating func appendInterpolation(value: Int) {
        self.appendLiteral("\(value)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ParkingLot.self, inMemory: true)
}
