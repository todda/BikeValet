//
//  EditLotName.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/20/25.
//

import SwiftUI
import SwiftData

struct EditLotName: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var parkingLots: [ParkingLot]
    @State var oldLot: ParkingLot
    @State var newLotName = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("From:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Lot:").font(.system(size: 26))
                        Spacer()
                        Text("\(oldLot.lotName)").font(.system(size: 26))
                    }
                }
                .padding(20)
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.gray.opacity(0.10)))

                Text("To:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("New Name:").font(.system(size: 26))
                        Spacer()
                        TextField("new bay", text: $newLotName)
                            .frame(width: 200)
                            .background(.white)
                            .font(.system(size: 26))
                            .multilineTextAlignment(.trailing)
                            .onAppear() { newLotName = "\(oldLot.lotName)" }
                    }
                }
                .padding(20)
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.blue.opacity(0.20)))

                Spacer()
                HStack {
                    Button("Remove") {
                        oldLot.slots.removeAll(where: { $0.zoneName == oldLot.lotName })
                        modelContext.delete(oldLot)
                        do {
                            try modelContext.save()
                        } catch {
                            print ("oh no")
                        }
                        dismiss()
                    }
                    Spacer()
                    Button("Save") {
                        print("renaming from: \(oldLot.lotName) to: \(newLotName)")

                        // Create new lot
                        modelContext.insert(ParkingLot(name: newLotName))

                        // Move slots over
                        for lot in 0..<parkingLots.count {
                            print("dumping lot:\(parkingLots[lot].lotName) at index: \(lot)")
                            for slot in parkingLots[lot].slots {
                                print("dumping id:\(slot.badgeId) zone:\(slot.zoneName)")
                            }
                        }
                        let mainLot = parkingLots.firstIndex(where: { $0.slots.count > 0 })!
                        print("moving \(parkingLots[mainLot].slots.filter({ $0.zoneName == oldLot.lotName}).count) parked items")
                        parkingLots[mainLot].moveZone(from: oldLot.lotName, to: newLotName)

                        // Remove old lot
                        modelContext.delete(oldLot)

                        do {
                            try modelContext.save()
                        } catch {
                            print ("oh no")
                        }
                        dismiss()
                    }
                }.padding(16)
            }.padding(16)
        }.frame(minWidth: 400, minHeight: 600).padding(16)
    }
}

#Preview {
//    EditParkedItem(oldSlot: ParkingSlot(badgeId: "12345123451234512345", lot: ParkingLot(name: "main")))
    EditLotName(oldLot: ParkingLot(name: "main"))
}
