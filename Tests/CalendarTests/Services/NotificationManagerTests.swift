//
//  NotificationManagerTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

/// A simple stub conforming to our protocol for testing.
final class NotificationCenterStub: NotificationCenterProtocol {
    var addedIdentifiers: [String] = []
    var removedIdentifiers: [String] = []

    func add(_ request: UNNotificationRequest) async throws {
        addedIdentifiers.append(request.identifier)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}

@MainActor
final class NotificationManagerTests: XCTestCase {
    private var stubCenter: NotificationCenterStub!
    private var manager: NotificationManager!
    private var ctx: NSManagedObjectContext!
    
    override func setUp() {
            super.setUp()

            // 1) In-memory Core Data stack for creating EventItem
            let container = NSPersistentContainer(name: "Calendar")
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores { storeDescription, error in
                if let err = error {
                    XCTFail("Failed to load in-memory store: \(err)")
                }
            }
            ctx = container.viewContext

            // 2) Stub and manager under test
            stubCenter = NotificationCenterStub()
            manager   = NotificationManager(center: stubCenter)
        }
    
    func testScheduleNotificationAddsRequest() async {
          // GIVEN an EventItem in our in-memory context
          let e = EventItem(context: ctx)
          e.id                   = UUID()
          e.eventDate            = Date()
          e.notificationsEnabled = true
          e.title                = "Reminder"
          e.details              = "This is a test"
          e.recurrence           = .none    // use the enum directly
          try? ctx.save()

          // WHEN we schedule it
          await manager.scheduleNotification(event: e)

          // THEN our stub saw exactly that identifier
          XCTAssertEqual(stubCenter.addedIdentifiers, [e.id!.uuidString])
      }

    func testRemovePendingNotificationRemovesFromCenter() {
        // GIVEN a stub center pre-populated with identifiers
        let stub = NotificationCenterStub()
        stub.addedIdentifiers = ["a", "b", "c"]
        let manager = NotificationManager(center: stub)

        // WHEN removing identifier "b"
        manager.removePendingNotification(identifier: "b")

        // THEN the stub recorded the removal correctly
        XCTAssertEqual(stub.removedIdentifiers, ["b"])
    }
}
