//
//  RepeatFrequencyTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
@testable import Calendar


final class RepeatFrequencyTests: XCTestCase {

    func test_DisplayNames() {
        XCTAssertEqual(RepeatFrequency.none.displayName,    "Never")
        XCTAssertEqual(RepeatFrequency.daily.displayName,   "Daily")
        XCTAssertEqual(RepeatFrequency.weekly.displayName,  "Weekly")
        XCTAssertEqual(RepeatFrequency.monthly.displayName, "Monthly")
        XCTAssertEqual(RepeatFrequency.yearly.displayName,  "Yearly")
    }

    func test_CalendarComponentMapping() {
        XCTAssertEqual(RepeatFrequency.daily.calendarComponent,   .day)
        XCTAssertEqual(RepeatFrequency.weekly.calendarComponent,  .weekOfYear)
        XCTAssertEqual(RepeatFrequency.monthly.calendarComponent, .month)
        XCTAssertEqual(RepeatFrequency.yearly.calendarComponent,  .year)
        XCTAssertNil(RepeatFrequency.none.calendarComponent)
    }
}
