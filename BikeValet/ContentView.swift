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
    @Query private var items: [Item]

    var body: some View {
        VStack {
            HStack {
                Text("299")
                Spacer()
                Button("", systemImage: "gearshape.fill", action: {
                })
            }.padding(100)
            Spacer()
            VStack {
                Text("OHSU38493-384839-3333").font(.system(size: 26))
                Text("333").font(.system(size: 96))
            }
            Spacer()
            HStack {
                Text("122")
                Spacer()
                Button("", systemImage: "gearshape.fill", action: {
                })
            }.padding(100)
        }
    }

    private func editItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
