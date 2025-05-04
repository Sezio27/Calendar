//
//  HolidayServiceTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

final class HolidayServiceTests: XCTestCase {
    private let ctx     = NSManagedObjectContext.test
        private lazy var service = HolidayService(context: ctx)
    
    override func setUp() {
        super.setUp()
        let delete = NSBatchDeleteRequest(fetchRequest: HolidayItem.fetchRequest())
        _ = try? ctx.execute(delete)
    }
    func testInfoForDayReturnsStoredHoliday() async {
            // GIVEN
            let date = Calendar.current.startOfDay(for: Date())
            let item = HolidayItem(context: ctx)
            item.id    = UUID()
            item.title = "Test Holiday"
            item.date  = date
            item.year  = Int16(Calendar.current.component(.year, from: date))
            try? ctx.save()

            // WHEN
            let result = await service.info(for: date)

            // THEN
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.title, "Test Holiday")
        }
    func testPreloadSkipsWhenDataAlreadyPresent() async {
        let row = HolidayItem(context: ctx)
        row.id    = UUID()
        row.title = "Dummy"
        row.date  = Date()
        row.year  = 2025
        try? ctx.save()
        
        let before = (try? ctx.count(for: HolidayItem.fetchRequest())) ?? -1
        
        await service.preload(year: 2025)
        
        let after = (try? ctx.count(for: HolidayItem.fetchRequest())) ?? -1
        XCTAssertEqual(after, before)
    }
}
