//
//  EventItem+EndTime.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

//  EventItem+EndTime.swift
import Foundation
import CoreData

extension EventItem {

    /// End-of-this-occurrence as an absolute `Date`
    private func endDate(for occurrenceDate: Date,
                         using calendar: Calendar = .current) -> Date {

        if let endTime {
            let t = calendar.dateComponents([.hour, .minute, .second], from: endTime)
            return calendar.date(bySettingHour: t.hour ?? 0,
                                 minute:      t.minute ?? 0,
                                 second:      t.second ?? 0,
                                 of:          occurrenceDate)!
        }

        if let start = eventDate {
            let t = calendar.dateComponents([.hour, .minute, .second], from: start)
            return calendar.date(bySettingHour: t.hour ?? 0,
                                 minute:      t.minute ?? 0,
                                 second:      t.second ?? 0,
                                 of:          occurrenceDate)!
        }

        return calendar.date(byAdding: .day,
                             value: 1,
                             to: calendar.startOfDay(for: occurrenceDate))!
    }

    func hasFinished(on occurrenceDate: Date,
                     relativeTo now: Date = Date(),
                     using calendar: Calendar = .current) -> Bool {
        now >= endDate(for: occurrenceDate, using: calendar)
    }
}
