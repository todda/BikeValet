//
//  EditParkedItemView.swift
//  BikeValet
//
//  Created on 11/20/25.
//

import SwiftUI
import SwiftData

struct EditParkedItem: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var parkingSlots: [CombinedZoneParkingSlot]
    @Query private var parkingLots: [ParkingLot]
    @State var oldSlot: CombinedZoneParkingSlot
    @State var newBayNumber = ""
    @State var selectedLot = 0
    @State var isShowingErrorMessage = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("From:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ID:").font(.system(size: 26))
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer()
                                Text("\(oldSlot.badgeId)").font(.system(size: 26))
                                    .textSelection(.enabled)
                            }.containerRelativeFrame(.horizontal, alignment: .trailing)
                        }
                    }
                    HStack {
                        Text("Lot:").font(.system(size: 26))
                        Spacer()
                        Text("\(oldSlot.zoneName)").font(.system(size: 26))
                    }
                    HStack {
                        Text("Bay:").font(.system(size: 26))
                        Spacer()
                        Text("\(value: oldSlot.bayNumber)").font(.system(size: 26))
                            .textSelection(.enabled)
                    }
                }
                .padding(20)
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.gray.opacity(0.10)))

                Text("To:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ID:").font(.system(size: 26))
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer()
                                Text("\(oldSlot.badgeId)").font(.system(size: 26))
                                    .textSelection(.enabled)
                            }.containerRelativeFrame(.horizontal, alignment: .trailing)
                        }
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
                        TextField("new bay", text: $newBayNumber)
                            .font(.system(size: 26))
                            .multilineTextAlignment(.trailing)
                            .onAppear() { newBayNumber = "\(oldSlot.bayNumber)" }
                            .onSubmit {
                                // check if slot is valid
                                if (parkingSlots.contains(where: {$0.bayNumber == Int(newBayNumber) && $0.lot!.lotName == oldSlot.zoneName})) {
                                    isShowingErrorMessage = true
                                } else {
                                    isShowingErrorMessage = false
                                }
                            }
                    }
                }
                .padding(20)
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.blue.opacity(0.20)))

                if (isShowingErrorMessage) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Error: that slot is currently not available").font(.system(size: 26)).accentColor(.red)
                    }
                    .padding(20)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .fill(Color.red.opacity(0.50)))
                }

                Spacer()
                HStack {
                    Button("Remove") {
                        oldSlot.lot!.slots!.removeAll(where: { $0.badgeId == oldSlot.badgeId })
                        modelContext.delete(oldSlot)
                        do {
                            try modelContext.save()
                        } catch {
                            print ("oh no")
                        }
                        dismiss()
                    }
                    Spacer()
                    Button("Save") {
                        let mainLot = parkingLots.firstIndex(where: { $0.slots!.count > 0 })!
                        let newSlot = CombinedZoneParkingSlot(badgeId: oldSlot.badgeId, bayNumber: Int(newBayNumber) ?? 0, lot: parkingLots[mainLot], zone:parkingLots[selectedLot].lotName)
                        oldSlot.lot!.slots!.removeAll(where: { $0.badgeId == oldSlot.badgeId })
                        if (newSlot.bayNumber > (parkingLots[mainLot].slots!.count + 1)) {
                            // TODO: custom error message variable?
                            isShowingErrorMessage = true
                        } else {
                            if (newSlot.bayNumber < parkingLots[selectedLot].slots!.count) {
                                parkingLots[mainLot].slots!.insert(newSlot, at: Int(newBayNumber) ?? newSlot.bayNumber)
                            } else {
                                parkingLots[mainLot].slots!.append(newSlot)
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
                }.padding(16)
            }.padding(16)
        }.frame(minWidth: 400, minHeight: 600).padding(16)
    }
}

#Preview {
    EditParkedItem(oldSlot: CombinedZoneParkingSlot(badgeId: "12345123451234512345", lot: ParkingLot(name: "main")))
}
