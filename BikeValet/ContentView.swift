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
    @Query private var parkingSlots: [CombinedZoneParkingSlot]

    @State private var selectedLotId: Int = 0
    @State private var cardNumber: String = ""
    @State private var lastCardNumber: String = ""
    @State private var checkedIn: Bool = false
    @FocusState private var focusConfirm: Bool
    @State private var occupiedSlot: CombinedZoneParkingSlot? = nil

    var body: some View {
        let mainLot = parkingLots.firstIndex(where: { ($0.slots!.count > 0 || $0.lotName == "Main") })!

        NavigationStack {
            VStack {
                HStack {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text(Image(systemName: "gearshape.fill"))
                    }
                    Spacer()
                    NavigationLink {
                        if (parkingSlots.count > 0) {
                            EditParkedItem(oldSlot: parkingSlots[parkingSlots.count - 1])
                        }
                    } label: {
                        Text("Edit Last")
                    }
                }.padding(16)
                Spacer()
                HStack {
                    Picker(selection: $selectedLotId, label: Text("Current Lot:")) {
                        ForEach(0 ..< parkingLots.count, id: \.self) {
                            Text(parkingLots[$0].lotName)
                        }
                    }.pickerStyle(.segmented)
                }.padding(10)

                TextField("Waiting for card scan", text: $cardNumber)
                    .font(.system(size: 26))
                    .focused($focusConfirm)
                    .textSelection(.disabled)
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(.accent))
                    .multilineTextAlignment(.center)
                    .onAppear() {
                        focusConfirm = true
                    }
                    .onSubmit {
                        occupiedSlot = parkingSlots.first(where: { $0.badgeId == cardNumber })
                        if ((occupiedSlot) != nil) {
                            checkedIn = true
                            //occupiedSlot!.lot.slots.remove(at: occupiedSlot!.bayNumber)
                            //occupiedSlot!.lot.slots.removeAll(where: { $0.bayNumber == occupiedSlot!.bayNumber })
                            //modelContext.delete(occupiedSlot!)
                        } else {
                            checkedIn = false
//                            occupiedSlot = ParkingSlot(badgeId: cardNumber, lot: parkingLots[selectedLotId])
                            occupiedSlot = CombinedZoneParkingSlot(badgeId: cardNumber, lot: parkingLots[mainLot], zone: parkingLots[selectedLotId].lotName)
                            parkingLots[mainLot].slots!.append(occupiedSlot!)
                            //modelContext.insert(occupiedSlot!)
                            do {
                                try modelContext.save()
                            } catch {
                                print ("oh no")
                            }
                        }
                        lastCardNumber = cardNumber
                        cardNumber = ""
                        focusConfirm = true
                        selectedLotId = 0
                    }

                Text("Last card scanned: \(lastCardNumber)")

                HStack {
                    Text("\(checkedIn ? "Out" : "In")").font(.system(size: 26))
                        .frame(width: UIScreen.main.bounds.size.width * 0.2)
                    Text("\(occupiedSlot?.zoneName ?? "Unknown Lot")").font(.system(size: 26))
                        .frame(width: UIScreen.main.bounds.size.width * 0.4)
                    Text("\(value: occupiedSlot?.bayNumber ?? 0)").font(.system(size: 106))
                        .frame(width: UIScreen.main.bounds.size.width * 0.2)
                }
                .frame(height: UIScreen.main.bounds.size.height * 0.3)
                .fixedSize()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill((checkedIn ? Color.accentColor : Color.green).opacity(0.50)))

                Spacer()

                HStack {
                    Text("Current Checkins: \(value: parkingSlots.count)")
                    Spacer()
                }.padding(16)
            }.padding(16)
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
