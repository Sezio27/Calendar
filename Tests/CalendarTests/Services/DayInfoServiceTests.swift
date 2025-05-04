//
//  DayInfoServiceTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

final class DayInfoServiceTests: XCTestCase {
    private let ctx = NSManagedObjectContext.test
    private let service = DayInfoService(context: MockPersistenceController.shared.viewContext)

    private func insertCachedItem(for date: Date) {
        let item       = DayInfoItem(context: ctx)
        item.date      = date
        item.sunrise   = "05:30"
        item.sunset    = "20:55"
        item.tempMin   = 5
        item.tempMax   = 9
        try? ctx.save()
    }

    func testReturnsCachedItemWithoutNetwork() async throws {
        let today = Calendar.current.startOfDay(for: .now)
        insertCachedItem(for: today)

        let result = await service.info(for: today)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sunrise, "05:30")
    }

    func testFutureDateImmediatelyNil() async throws {
        let future = Calendar.current.date(byAdding: .day, value: 3, to: .now)!

        let result = await service.info(for: future)

        XCTAssertNil(result, "Service must not hit the network for future dates")
    }
}
