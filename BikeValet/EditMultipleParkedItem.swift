//
//  EditMultipleParkedItemView.swift
//  BikeValet
//
//  Created on 1/28/26.
//

import SwiftUI
import SwiftData

struct EditMultipleParkedItem: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var parkingSlots: [CombinedZoneParkingSlot]
    @Query private var parkingLots: [ParkingLot]
    @State var oldSlots: [CombinedZoneParkingSlot]
    @State var newBayNumber = ""
    @State var selectedLot = 0
    @State var isShowingErrorMessage = false

    var body: some View {
//        let combinedBays = oldSlots.compactMap({String($0.bayNumber)}).joined(separator: ",")
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("From:").font(.system(size: 26))
                List {
                    ForEach(oldSlots.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("ID: ").font(.system(size: 26))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Text("\(oldSlots[index].badgeId)").font(.system(size: 26))
                                            .textSelection(.enabled)
                                    }
                                }
                                
                                Text("Lot: \(oldSlots[index].zoneName)").font(.system(size: 26))
                                Spacer()
                                Text("Bay: \(oldSlots[index].bayNumber)").font(.system(size: 26))
                                    .textSelection(.enabled)
                            }
                        }
                        .padding(10)
                        .frame(height: 80)
                        .background(RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.gray.opacity(0.10)))
                    }
                }

                Text("To:").font(.system(size: 26))
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Lot:").font(.system(size: 26))
                        Spacer()
                        Picker(selection: $selectedLot, label: Text("lot:")) {
                            ForEach(0 ..< parkingLots.count, id: \.self) {
                                Text(parkingLots[$0].lotName)
                            }
                        }.frame(width: 120.0, alignment: .trailing).labelsHidden()
                    }
                }
                .padding(20)
                .frame(height: 50)
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
                        for index in oldSlots.indices {
                            modelContext.delete(oldSlots[index])
                        }
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
                        for index in oldSlots.indices {
                            let newSlot = CombinedZoneParkingSlot(badgeId: oldSlots[index].badgeId,
                                                                  bayNumber: oldSlots[index].bayNumber,
                                                                  lot: parkingLots[mainLot],
                                                                  zone:parkingLots[selectedLot].lotName)
                            modelContext.delete(oldSlots[index])
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
    let tempLot = ParkingLot(name: "main")
    EditMultipleParkedItem(oldSlots: [
        CombinedZoneParkingSlot(badgeId: "12345123451234512345", lot: tempLot, zone: "main"),
        CombinedZoneParkingSlot(badgeId: "51234512345123451234", lot: tempLot, zone: "main"),
        CombinedZoneParkingSlot(badgeId: "25432312345123451234", lot: tempLot, zone: "foo")
    ])
}
