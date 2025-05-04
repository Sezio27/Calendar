//
//  EventViewModelTests.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest
import CoreData
@testable import Calendar

final class StubNotificationCenter: NotificationCenterProtocol {
    var scheduledIDs: [String] = []
    var removedIDs: [String] = []
    
    func add(_ request: UNNotificationRequest) async throws {
        scheduledIDs.append(request.identifier)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIDs.append(contentsOf: identifiers)
    }
}

final class StubNotificationManager: NotificationManager {
    private let centerStub: StubNotificationCenter
    
    init(stub: StubNotificationCenter) {
        self.centerStub = stub
        super.init(center: stub)
    }
    
    override func scheduleNotification(event: EventItem) async {
        if let id = event.id?.uuidString {
            centerStub.scheduledIDs.append(id)
        }
    }
    
    override func removePendingNotification(identifier: String) {
        centerStub.removedIDs.append(identifier)
    }
}

@MainActor
final class EventViewModelTests: XCTestCase {
    private var ctx: NSManagedObjectContext!
    private var stubCenter: StubNotificationCenter!
    private var stubNotif: StubNotificationManager!
    private var holidayService: HolidayService!
    private var dayInfoService: DayInfoService!
    private var vm: EventViewModel!
    
    override func setUp() {
        super.setUp()
        
        ctx = NSManagedObjectContext.test
        let delete = NSBatchDeleteRequest(fetchRequest: EventItem.fetchRequest())
        _ = try? ctx.execute(delete)
        ctx.reset()
        
        stubCenter     = StubNotificationCenter()
        stubNotif      = StubNotificationManager(stub: stubCenter)
        holidayService = HolidayService(context: ctx)
        dayInfoService = DayInfoService(context: ctx)
        vm = EventViewModel(
            context: ctx,
            notifications: stubNotif,
            holidayService: holidayService,
            dayInfoService: dayInfoService
        )
    }
    
    override func tearDown() {
        vm = nil
        stubNotif = nil
        stubCenter = nil
        ctx = nil
        super.tearDown()
    }
    
    func testFetchEventsInitiallyEmpty() {
        XCTAssertTrue(vm.events.isEmpty)
    }
    
    func testAddEventPersistsAndSchedulesNotification() async {
        let today = Date()
        vm.addEvent(
            title: "Test",
            date: today,
            endTime: nil,
            details: "Test",
            color: .blue,
            recurrence: .none,
            notificationsEnabled: true
        )
        
        await Task.yield()
        
        XCTAssertEqual(vm.events.count, 1)
        let e = vm.events[0]
        XCTAssertEqual(e.title, "Test")
        XCTAssertEqual(stubCenter.scheduledIDs, [e.id!.uuidString])
    }
    
    func testEventsForDayFiltersCorrectly() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        
        vm.addEvent(title: "A", date: today, endTime: nil, details: "", color: .red, recurrence: .none, notificationsEnabled: false)
        vm.addEvent(title: "B", date: tomorrow, endTime: nil, details: "", color: .red, recurrence: .none, notificationsEnabled: false)
        let todays = vm.eventsForDay(today)
        XCTAssertEqual(todays.count, 1)
        XCTAssertEqual(todays[0].title, "A")
    }
    
    func testUpdateEventModifiesAndReschedulesNotification() async {
        vm.addEvent(title: "Old", date: Date(), endTime: nil, details: "", color: .green, recurrence: .none, notificationsEnabled: true)
        await Task.yield()
        let event = vm.events[0]
        stubCenter.scheduledIDs.removeAll()
        stubCenter.removedIDs.removeAll()
        
        let newDate = Date().addingTimeInterval(3600)
        vm.updateEvent(event: event, title: "New", time: newDate, endTime: nil, details: "Updated", color: .blue, recurrence: .none, notificationsEnabled: true)
        await Task.yield()
        let updated = vm.events.first(where: { $0.id == event.id })!
        XCTAssertEqual(updated.title, "New")
        print(stubCenter.removedIDs)
        print([event.id!.uuidString])
        XCTAssertEqual(stubCenter.removedIDs, [event.id!.uuidString])
        XCTAssertEqual(stubCenter.scheduledIDs, [event.id!.uuidString])
    }
    
    func testSplitEventNonRecurringUpdatesOnly() {
        let date0 = Date()
        vm.addEvent(title: "X", date: date0, endTime: nil, details: "", color: .blue, recurrence: .none, notificationsEnabled: false)
        let event = vm.events[0]
        
        vm.splitEvent(original: event, occurrenceDate: date0, notificationsEnabled: false, newTitle: "Y", newDetails: "", newColor: .red, newEndTime: nil)
        
        XCTAssertEqual(vm.events.count, 1)
        XCTAssertEqual(vm.events[0].title, "Y")
    }
    
    func testSplitEventRecurringCreatesClone() {
        let cal = Calendar.current
        let base = cal.startOfDay(for: Date())
        vm.addEvent(title: "R", date: base, endTime: nil, details: "", color: .blue, recurrence: .weekly, notificationsEnabled: false)
        let event = vm.events[0]
        let occurrence = cal.date(byAdding: .day, value: 7, to: base)!
        
        vm.splitEvent(original: event, occurrenceDate: occurrence, notificationsEnabled: false, newTitle: "S", newDetails: "", newColor: .green, newEndTime: nil)
        
        XCTAssertEqual(vm.events.count, 2)
        XCTAssertTrue((event.exceptionDates as? [Date] ?? []).contains(where: { cal.isDate($0, inSameDayAs: occurrence) }))
    }
    
    func testDeleteEventRemovesAndCancels() async {
        vm.addEvent(title: "D", date: Date(), endTime: nil, details: "", color: .blue, recurrence: .none, notificationsEnabled: true)
        await Task.yield()
        XCTAssertEqual(vm.events.count, 1)
        let event = vm.events[0]
        let id = event.id!.uuidString
        vm.deleteEvent(event: event)
        XCTAssertTrue(vm.events.isEmpty)
        XCTAssertEqual(stubCenter.removedIDs, [id])
    }
    
    func testDeleteAllEventsEmptiesStoreAndCancels() {
        vm.addEvent(title: "A1", date: Date(), endTime: nil, details: "", color: .blue, recurrence: .none, notificationsEnabled: true)
        vm.addEvent(title: "A2", date: Date(), endTime: nil, details: "", color: .blue, recurrence: .none, notificationsEnabled: true)
        let originalIDs = vm.events.map { $0.id!.uuidString }
        
        vm.deleteAllEvents()
        
        XCTAssertTrue(vm.events.isEmpty)
        XCTAssertEqual(Set(stubCenter.removedIDs), Set(originalIDs))
    }
}



