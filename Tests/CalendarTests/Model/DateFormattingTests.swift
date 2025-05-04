//
//  DateFormattingTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
@testable import Calendar

final class DateFormattingTests: XCTestCase {

    func test_MonthYearString_EnglishLocale() {
        // GIVEN 3 May 2025 created with the same calendar the app uses
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 5, day: 3))!

        // WHEN
        let rendered = date.monthYearString()

        // THEN
        XCTAssertEqual(rendered, "May 2025")
    }
}
