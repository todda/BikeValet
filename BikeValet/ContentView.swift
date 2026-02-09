//
//  ContentView.swift
//  BikeValet
//
//  Created on 11/10/25.
//

import SwiftUI
import SwiftData

struct HistoryItem: Identifiable {
    var id: UUID = UUID()
    var zone = ""
    var bay = ""
}

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
    static let MAX_HISTORY = 3
    @State private var history: [HistoryItem] = Array(repeating: HistoryItem(zone: "unknown", bay: "?"), count: MAX_HISTORY)

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
                        history.push(HistoryItem(zone: "\(checkedIn ? "-" : "+") \(occupiedSlot?.zoneName ?? "Unknown Lot")",
                                                 bay: "\(value: occupiedSlot?.bayNumber ?? 0)"))
                        occupiedSlot = parkingSlots.first(where: { $0.badgeId == cardNumber })
                        if ((occupiedSlot) != nil) {
                            checkedIn = true
                        } else {
                            checkedIn = false
                            occupiedSlot = CombinedZoneParkingSlot(badgeId: cardNumber, lot: parkingLots[mainLot], zone: parkingLots[selectedLotId].lotName)
                            parkingLots[mainLot].slots!.append(occupiedSlot!)
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
                    .textSelection(.enabled)

                HStack {
                    Text("\(checkedIn ? "-" : "+") \(occupiedSlot?.zoneName ?? "Unknown Lot")").font(.system(size: 56))
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.size.width * 0.6)
                    Text("\(value: occupiedSlot?.bayNumber ?? 0)").font(.system(size: 106))
                        .textSelection(.enabled)
                        .fontWeight(.heavy)
                        .frame(width: UIScreen.main.bounds.size.width * 0.4)
                }
                .frame(height: UIScreen.main.bounds.size.height * 0.2)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill((checkedIn ? Color.accentColor : Color.green).opacity(0.50)))

                ForEach(history) { historyElement in
                    HStack {
                        Text("\(historyElement.zone)").font(.system(size: 28))
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width * 0.4)
                        Text(historyElement.bay).font(.system(size: 54))
                            .textSelection(.enabled)
                            .fontWeight(.heavy)
                            .frame(width: UIScreen.main.bounds.size.width * 0.2)
                    }
                    .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color.gray.opacity(0.20)))
                }

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

extension Array {
    mutating func push(_ newObject: Element) {
        for (index, element) in self.enumerated().reversed() {
            if (self.count-1 != index) {
                self[index + 1] = element
            }
        }
        self[0] = newObject
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ParkingLot.self, inMemory: true)
}
