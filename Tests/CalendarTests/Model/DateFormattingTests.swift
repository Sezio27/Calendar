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
      
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 5, day: 3))!

        let rendered = date.monthYearString()

        XCTAssertEqual(rendered, "May 2025")
    }
}
