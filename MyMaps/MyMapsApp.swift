//
//  MyMapsApp.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

@main
struct MyMapsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
