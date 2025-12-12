//
//  EditParkedItemView.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/20/25.
//

import SwiftUI
import SwiftData

struct EditParkedItem: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var parkingSlots: [ParkingSlot]
    @Query private var parkingLots: [ParkingLot]
    @State var oldSlot: ParkingSlot
    @State var newBayNumber = ""
    @State var selectedLot = 0
    @State var isShowingErrorMessage = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("From:").font(.system(size: 26)).frame(alignment: .leading)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ID:").font(.system(size: 26))
                        Spacer()
                        Text("\(oldSlot.badgeId)").font(.system(size: 26))
                    }
                    HStack {
                        Text("Lot:").font(.system(size: 26))
                        Spacer()
                        Text("\(oldSlot.lot.lotName)").font(.system(size: 26))
                    }
                    HStack {
                        Text("Bay:").font(.system(size: 26))
                        Spacer()
                        Text("\(value: oldSlot.bayNumber)").font(.system(size: 26))
                    }
                }
                .frame(height: 200)
                .fixedSize()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.gray.opacity(0.10)))

                Text("To:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ID:").font(.system(size: 26))
                        Spacer()
                        Text("\(oldSlot.badgeId)").font(.system(size: 26))
                    }
                    HStack {
                        Text("Lot:").font(.system(size: 26))
                        Spacer()
                        Picker(selection: $selectedLot, label: Text("lot:")) {
                            ForEach(0 ..< parkingLots.count, id: \.self) {
                                Text(parkingLots[$0].lotName)
                            }
                        }.frame(width: 120.0, alignment: .trailing).labelsHidden()
                    }
                    HStack {
                        Text("Bay:").font(.system(size: 26))
                        Spacer()
                        TextField("new bay", text: $newBayNumber).font(.system(size: 26)).multilineTextAlignment(.center)
                        .onSubmit {
                            // check if slot is valid
                            if (parkingSlots.contains(where: {$0.bayNumber == Int(newBayNumber)})) {
                                isShowingErrorMessage = true
                            } else {
                                isShowingErrorMessage = false
                            }
                        }
                    }
                }.frame(height: 200)
                .fixedSize()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.blue.opacity(0.20)))

                if (isShowingErrorMessage) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Error: that slot is currently not available").font(.system(size: 26)).accentColor(.red)
                    }.frame(height: 200)
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.red.opacity(0.50)))
                }

                Spacer()
                Button("Save") {
                    let newSlot = ParkingSlot(badgeId: oldSlot.badgeId, bayNumber: Int(newBayNumber) ?? 0, lot: parkingLots[selectedLot])
                    oldSlot.lot.slots.remove(at: oldSlot.lot.slots.firstIndex(of: oldSlot)!)
                    if (newSlot.bayNumber < parkingLots[selectedLot].slots.count) {
                        parkingLots[selectedLot].slots.insert(newSlot, at: Int(newBayNumber) ?? newSlot.bayNumber)
                    } else {
                        parkingLots[selectedLot].slots.append(newSlot)
                    }
                    modelContext.delete(oldSlot)
                    modelContext.insert(newSlot)
                    do {
                        try modelContext.save()
                    } catch {
                        print ("oh no")
                    }
                    dismiss()
                }
            }
        }.frame(minWidth: 400, minHeight: 600).padding(16)
    }
}

#Preview {
    EditParkedItem(oldSlot: ParkingSlot(badgeId: "12345", lot: ParkingLot(name: "main")))
}
