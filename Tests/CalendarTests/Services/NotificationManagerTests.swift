//
//  NotificationManagerTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

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
    private let ctx     = NSManagedObjectContext.test
    
    override func setUp() {
            super.setUp()
            stubCenter = NotificationCenterStub()
            manager   = NotificationManager(center: stubCenter)
        }
    
    func testScheduleNotificationAddsRequest() async {
          let e = EventItem(context: ctx)
          e.id                   = UUID()
          e.eventDate            = Date()
          e.notificationsEnabled = true
          e.title                = "Reminder"
          e.details              = "This is a test"
          e.recurrence           = .none
          try? ctx.save()

          await manager.scheduleNotification(event: e)

          XCTAssertEqual(stubCenter.addedIdentifiers, [e.id!.uuidString])
      }

    func testRemovePendingNotificationRemovesFromCenter() {
        let stub = NotificationCenterStub()
        stub.addedIdentifiers = ["a", "b", "c"]
        let manager = NotificationManager(center: stub)

        manager.removePendingNotification(identifier: "b")

        XCTAssertEqual(stub.removedIdentifiers, ["b"])
    }
}
