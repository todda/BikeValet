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
    @AppStorage("MagicPrizeNumber") private var magicNumber = 0
    @AppStorage("UsePrizeFeature") private var usePrizeFeature = false
    @Query private var parkingLots: [ParkingLot]

    @State private var selectedLotId: Int = 0
    @State private var cardNumber: String = ""
    @State private var lastCardNumber: String = ""
    @State private var checkedIn: Bool = false
    @FocusState private var focusConfirm: Bool
    @State private var occupiedSlot: CombinedZoneParkingSlot? = nil
    static let MAX_HISTORY = 3
    @State private var history: [HistoryItem] = Array(repeating: HistoryItem(zone: "unknown", bay: "?"), count: MAX_HISTORY)
    @State private var lastEmoji = String.randomEmoji

    var body: some View {
        let mainLot = parkingLots.firstIndex(where: { (nil != $0.slots && ($0.slots!.count > 0 || $0.lotName == "Main")) })!

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
                        if (nil != parkingLots[mainLot].slots && parkingLots[mainLot].slots!.count > 0) {
                            EditParkedItem(oldSlot: parkingLots[mainLot].slots![parkingLots[mainLot].slots!.count - 1])
                        }
                    } label: {
                        Text("Edit Last")
                    }
                }.padding(16)

                if (usePrizeFeature) {
                    Text(lastEmoji).font(.system(size: 156)).fontWeight(.bold)
                } else {
                    Spacer()
                }

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
                        occupiedSlot = parkingLots[mainLot].slots?.first(where: { $0.badgeId == cardNumber })
                        if ((occupiedSlot) != nil) {
                            checkedIn = true
                        } else {
                            checkedIn = false
                            occupiedSlot = CombinedZoneParkingSlot(badgeId: cardNumber,
                                                                   lot: parkingLots[mainLot],
                                                                   zone: parkingLots[selectedLotId].lotName)
                            modelContext.insert(occupiedSlot!)

                            do {
                                try modelContext.save()
                            } catch {
                                print ("oh no")
                            }
                        }
                        lastCardNumber = cardNumber
                        if (parkingLots[mainLot].slots!.count == magicNumber) {
                            lastEmoji = "🎁🎁🎁"
                        } else {
                            lastEmoji = String.randomEmoji
                        }
                        cardNumber = ""
                        focusConfirm = true
                        selectedLotId = 0
                    }

                Text("Last card scanned: \(lastCardNumber)")
                    .textSelection(.enabled)

                HStack {
                    Text("\(checkedIn ? "➖" : "➕")").font(.system(size: 106))
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.size.width * 0.15)
                    Text(" \(occupiedSlot?.zoneName ?? "Unknown Lot")").font(.system(size: 56))
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.size.width * 0.5)
                    Text("\(value: occupiedSlot?.bayNumber ?? 999)").font(.system(size: 106))
                        .textSelection(.enabled)
                        .fontWeight(.heavy)
                        .frame(width: UIScreen.main.bounds.size.width * 0.35)
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
                    Text("Current Checkins: \(value: parkingLots[mainLot].slots!.count)")
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

extension String {
    static var randomEmoji: String {
        let ranges: [ClosedRange<Int>] = [
            0x1f600...0x1f64f,
            0x1f680...0x1f6c5,
            0x1f6cb...0x1f6d2,
            0x1f6e0...0x1f6e5,
            0x1f6f3...0x1f6fa,
            0x1f7e0...0x1f7eb,
            0x1f90d...0x1f93a,
            0x1f93c...0x1f945,
            0x1f947...0x1f971,
            0x1f973...0x1f976,
            0x1f97a...0x1f9a2,
            0x1f9a5...0x1f9aa,
            0x1f9ae...0x1f9ca,
            0x1f9cd...0x1f9ff,
            0x1fa70...0x1fa73,
            0x1fa78...0x1fa7a,
            0x1fa80...0x1fa82,
            0x1fa90...0x1fa95,        ]
        let allCodePoints = ranges.flatMap { Array($0) }

        guard let codePoint = allCodePoints.randomElement(),
              let scalar = UnicodeScalar(codePoint) else {
            return "😀" // Fallback
        }

        return String(scalar)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ParkingLot.self, inMemory: true)
}
