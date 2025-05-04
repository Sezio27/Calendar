//
//  EventViewModel.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import Foundation
import CoreData
import UserNotifications
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [EventItem] = []
    
    private var viewContext: NSManagedObjectContext
    private let notifications: NotificationManager
    private let dayInfoService: DayInfoService
    private let holidayService: HolidayService
    
    init(context: NSManagedObjectContext,
         notifications: NotificationManager,
         holidayService: HolidayService = .shared,
         dayInfoService: DayInfoService = .shared
    ) {
        self.viewContext = context
        self.notifications = notifications
        self.holidayService = holidayService
        self.dayInfoService = dayInfoService
        fetchEvents()
    }
    
    
    func fetchEvents() {
        let request: NSFetchRequest<EventItem> = EventItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \EventItem.eventDate, ascending: true)]
        do {
            events = try viewContext.fetch(request)
        } catch {
            print("Error fetching events: \(error)")
        }
    }
    
    func eventsForDay(_ day: Date, using calendar: Calendar = .current) -> [EventItem] {
        events.filter { $0.occurs(on: day, using: calendar) }
    }
    
    func holidayForDay(_ day: Date) async -> HolidayItem? {
        await holidayService.info(for: day)
    }
    
    func dayInfoForDate(_ date: Date) async -> DayInfoItem? {
        await dayInfoService.info(for: date)
    }
    
    
    func addEvent(
            title: String,
            date: Date,
            endTime: Date?,
            details: String,
            color: EventColor,
            recurrence: RepeatFrequency,
            notificationsEnabled: Bool
        ) {
            let e = EventItem(context: viewContext)
            e.id                   = UUID()
            e.title                = title
            e.eventDate            = date
            e.endTime              = endTime
            e.details              = details
            e.eventColor           = color
            e.recurrence           = recurrence
            e.notificationsEnabled = notificationsEnabled

            saveContext()
            
            if notificationsEnabled {
                Task { await notifications.scheduleNotification(event: e) }
                    }
        }
    
    func updateEvent(event: EventItem, title: String, time: Date, endTime: Date?, details: String, color: EventColor, recurrence: RepeatFrequency, notificationsEnabled: Bool) {
        event.title = title
        event.eventDate = time
        event.endTime = endTime
        event.details = details
        event.eventColor = color
        event.recurrence  = recurrence
        event.notificationsEnabled = notificationsEnabled
        event.exceptionDates = nil
        event.repeatEndDate = nil
        objectWillChange.send()
        saveContext()
        
        if let id = event.id?.uuidString {
            notifications.removePendingNotification(identifier: id)
            if notificationsEnabled {
                Task { await notifications.scheduleNotification(event: event) }
                    }
        }
    }
    
    
    func splitEvent(
        original event: EventItem,
        occurrenceDate: Date,
        notificationsEnabled: Bool,
        newTitle: String,
        newDetails: String,
        newColor: EventColor,
        newEndTime: Date?
    ) {
        let calendar = Calendar.current

        if event.recurrence == .none {
            event.title = newTitle
            event.details = newDetails
            event.eventDate = occurrenceDate
            event.endTime = newEndTime
            event.eventColor = newColor
            event.notificationsEnabled = notificationsEnabled

            objectWillChange.send()
            saveContext()
            return
        }

        var exceptions = (event.exceptionDates as? [Date]) ?? []
        if !exceptions.contains(where: { Calendar.current.isDate($0, inSameDayAs: occurrenceDate) }) {
            exceptions.append(occurrenceDate)
            event.exceptionDates = exceptions as NSObject?
        }

        let clone = EventItem(context: viewContext)
        clone.id = UUID()
        clone.title = newTitle
        clone.details = newDetails
        clone.eventDate = occurrenceDate
        clone.endTime = newEndTime
        clone.eventColor = newColor
        clone.recurrence = .none
        clone.notificationsEnabled = notificationsEnabled

        saveContext()

        if notificationsEnabled {
            Task { await notifications.scheduleNotification(event: clone) }
                }
    }

    
    func deleteOccurrence(event: EventItem, on day: Date) {
        var exceptions = (event.exceptionDates as? [Date]) ?? []
        exceptions.append(day)
        event.exceptionDates = exceptions as NSObject?
        
        saveContext()

        if let id = event.id?.uuidString {
            notifications.removePendingNotification(identifier: id)
        }
    }
    
    
    func deleteEvent(event: EventItem) {
        if let id = event.id?.uuidString {
            notifications.removePendingNotification(identifier: id)
        }
        
        viewContext.delete(event)
        saveContext()

    }
    
    func deleteAllEvents() {
        for event in events {
            if let id = event.id?.uuidString {
                notifications.removePendingNotification(identifier: id)
            }
            viewContext.delete(event)
        }
        saveContext()

    }
    
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchEvents()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
}

