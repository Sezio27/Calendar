//
//  CalendarApp.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/25/25.
//

import SwiftUI

@main
struct CalendarApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var notificationManager = NotificationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notificationManager)
                .environmentObject(
                    EventViewModel(context: persistenceController.container.viewContext,
                                   notifications: notificationManager)
                )
        }
    }
}
