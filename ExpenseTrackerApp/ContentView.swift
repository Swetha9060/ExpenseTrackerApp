//
//  ContentView.swift
//  ExpenseTrackerApp
//
//  Created by Chaitanya Gajula on 24/05/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body : some View {
        
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
