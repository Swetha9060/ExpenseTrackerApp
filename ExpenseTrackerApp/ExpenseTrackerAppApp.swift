//
//  ExpenseTrackerAppApp.swift
//  ExpenseTrackerApp
//
//  Created by Chaitanya Gajula on 24/05/26.
//

import SwiftUI
import CoreData

@main
struct ExpenseTrackerAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
