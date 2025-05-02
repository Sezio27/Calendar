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
    
    
    init(context: NSManagedObjectContext,
         notifications: NotificationManager
    ) {
        self.viewContext = context
        self.notifications = notifications
        
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
    
    func addEvent(title: String, date: Date, endTime: Date?, details: String, color: EventColor, recurrence: RepeatFrequency, notificationsEnabled: Bool) {
        let newEvent = EventItem(context: viewContext)
        newEvent.id = UUID()
        newEvent.title = title
        newEvent.eventDate = date
        newEvent.endTime = endTime
        newEvent.details = details
        newEvent.eventColor = color
        newEvent.recurrence  = recurrence
        newEvent.notificationsEnabled = notificationsEnabled
        saveContext()
        fetchEvents()
        
        if notificationsEnabled {
            scheduleNotification(for: newEvent)
        }
    }
    
    func updateEvent(event: EventItem, title: String, date: Date, endTime: Date?, details: String, color: EventColor, recurrence: RepeatFrequency, notificationsEnabled: Bool) {
        event.title = title
        event.eventDate = date
        event.endTime = endTime
        event.details = details
        event.eventColor = color
        event.recurrence  = recurrence
        event.notificationsEnabled = notificationsEnabled
        
        objectWillChange.send()
        saveContext()
        fetchEvents()
        
        if let id = event.id?.uuidString {
            notifications.removePendingNotification(identifier: id)
            if notificationsEnabled {
                scheduleNotification(for: event)
            }
        }
    }
    
    
    func splitEvent(
        original event: EventItem,
        occurrenceDate: Date,
        newRecurrence: RepeatFrequency,
        notificationsEnabled: Bool,
        newTitle: String,
        newDetails: String,
        newColor: EventColor,
        newEndTime: Date?
    ) {
        let calendar = Calendar.current
        
        // 1) Truncate old series *the day before* this occurrence,
        //    so the old series no longer generates the occurrence itself or any after.
        if let dayBefore = calendar.date(
            byAdding: .day,
            value: -1,
            to: occurrenceDate
        ) {
            event.repeatEndDate = dayBefore
        } else {
            // fallback safety
            event.repeatEndDate = occurrenceDate
        }
        
        // 2) Save & reschedule the original series (only up to that truncated date)
        saveContext()
        if let id = event.id?.uuidString {
            notifications.removePendingNotification(identifier: id)
            scheduleNotification(for: event)   // will only fire up through dayBefore
        }
        
        // 3) Create a new EventItem for this occurrence
        let clone = EventItem(context: viewContext)
        clone.id                   = UUID()
        clone.title                = newTitle
        clone.details              = newDetails
        clone.eventDate            = occurrenceDate
        clone.endTime           = newEndTime
        clone.eventColor           = newColor
        clone.recurrence           = newRecurrence
        clone.notificationsEnabled = notificationsEnabled
        // recurrenceEndDate = nil by default
        
        // 4) Save & schedule the new series/one-off
        saveContext()
        fetchEvents()
        if notificationsEnabled {
            scheduleNotification(for: clone)
        }
    }
    
    func deleteOccurrence(event: EventItem, on day: Date) {
        // 1) Cast the raw transformable back to [Date]
        var exceptions = (event.exceptionDates as? [Date]) ?? []
        exceptions.append(day)
        event.exceptionDates = exceptions as NSObject?
        
        saveContext()
        fetchEvents()
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
        fetchEvents()
    }
    
    func holidayForDay(_ day: Date, using cal: Calendar = .current) -> HolidayItem? {
        let req: NSFetchRequest<HolidayItem> = HolidayItem.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            cal.startOfDay(for: day) as CVarArg,
            cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: day))! as CVarArg
        )
        return (try? viewContext.fetch(req))?.first
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func scheduleNotification(for event: EventItem) {
        guard
            let id        = event.id?.uuidString,
            let date      = event.eventDate,
            event.notificationsEnabled
        else {
            return
        }
        
        
        let (components, repeats) = makeTriggerComponents(
            for: date,
            frequency: event.recurrence
        )
        
        let localNotification = LocalNotification(
            identifier:     id,
            title:          event.title ?? "Event Reminder",
            body:           event.details ?? "",
            dateComponents: components,
            repeats:        repeats
        )
        
        // 2. Schedule on the next run loop after saveContext()
        Task {
            await notifications.schedule(localNotification: localNotification)
        }
    }
    
    private func makeTriggerComponents(
        for date: Date,
        frequency: RepeatFrequency
    ) -> (DateComponents, Bool) {
        switch frequency {
        case .none:
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            return (comps, false)
        case .daily:
            let comps = Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )
            return (comps, true)
        case .weekly:
            let comps = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: date
            )
            return (comps, true)
        case .monthly:
            let comps = Calendar.current.dateComponents(
                [.day, .hour, .minute],
                from: date
            )
            return (comps, true)
        case .yearly:
            let comps = Calendar.current.dateComponents(
                [.month, .day, .hour, .minute],
                from: date
            )
            return (comps, true)
        }
    }
}

