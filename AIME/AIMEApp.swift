//
//  AIMEApp.swift
//  AIME
//
//  Created by Galvin Gao on 3/6/23.
//

import SwiftUI

@main
struct AIMEApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
