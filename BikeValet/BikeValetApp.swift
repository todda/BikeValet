//
//  BikeValetApp.swift
//  BikeValet
//
//  Created by Todd Anderson on 11/10/25.
//

import SwiftUI
import SwiftData

@main
struct BikeValetApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ParkingLot.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            var itemFetchDescriptor = FetchDescriptor<ParkingLot>()
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            guard try container.mainContext.fetch(itemFetchDescriptor).count == 0 else { return container }
            let initialData: [ParkingLot] = [
                ParkingLot(name: "Main"),
                ParkingLot(name: "Oversized"),
            ]
            for lot in initialData {
                container.mainContext.insert(lot)
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
