//
//  EventItemTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

final class EventItemTests: XCTestCase {
    //helper
    private func makeEvent(on start: Date,
                           end: Date? = nil,
                           frequency: RepeatFrequency = .weekly) -> EventItem {
        let ctx = MockPersistenceController.shared.viewContext
        let e   = EventItem(context: ctx)

        e.id                   = UUID()
        e.title                = "Exam rehearsal"
        e.eventDate            = start
        e.endTime              = end
        e.eventColor           = .red
        e.notificationsEnabled = false
        e.recurrence           = frequency
        return e
    }

    func testOccursOnMatchingWeekday() {
        let cal  = Calendar.current
        let may3 = cal.date(from: DateComponents(year: 2025, month: 5, day: 3))! // Sat
        let sut  = makeEvent(on: may3)

        let nextWeekSameWeekday = cal.date(byAdding: .day, value: 7, to: may3)!
        XCTAssertTrue(sut.occurs(on: nextWeekSameWeekday))

        let nextDay = cal.date(byAdding: .day, value: 1, to: may3)!
        XCTAssertFalse(sut.occurs(on: nextDay))
    }

    func testHasFinishedWithoutEndTime() {
        let cal        = Calendar.current
        let oneHourAgo = cal.date(byAdding: .hour, value: -1, to: Date())!
        let sut        = makeEvent(on: oneHourAgo) 

        let now = Date() // 1 hour later
        XCTAssertTrue(sut.hasFinished(on: oneHourAgo, relativeTo: now))
    }

    func testHasFinishedRespectsEndTime() {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.date(bySettingHour: 20, minute: 0, second: 0, of: today)! // 20:00
        let end   = cal.date(bySettingHour: 21, minute: 0, second: 0, of: today)! // 21:00
        let sut   = makeEvent(on: start, end: end)

        // Before endTime
        let twentyThirty = cal.date(bySettingHour: 20, minute: 30, second: 0, of: today)!
        XCTAssertFalse(sut.hasFinished(on: start, relativeTo: twentyThirty))

        // After endTime
        let twentyOneOhFive = cal.date(bySettingHour: 21, minute: 5, second: 0, of: today)!
        XCTAssertTrue(sut.hasFinished(on: start, relativeTo: twentyOneOhFive))
    }
}

