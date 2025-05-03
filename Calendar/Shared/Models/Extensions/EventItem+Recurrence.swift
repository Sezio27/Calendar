//
//  EventItem+recurrence.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//
import Foundation
import CoreData

extension EventItem {
    
    var recurrence: RepeatFrequency {
        get {
            RepeatFrequency(rawValue: repeatFrequency) ?? .none
        }
        set {
            repeatFrequency = newValue.rawValue
        }
    }
    
    var shouldOfferSplit: Bool { self.recurrence != .none }
    
    func occurs(on day: Date, using calendar: Calendar = .current) -> Bool {
        
        if let raw = exceptionDates as? [Date],
               raw.contains(where: { calendar.isDate($0, inSameDayAs: day) }) {
              return false
            }
        
        guard let start = eventDate else { return false }

            // 0) If we have an end date, and `day` is strictly after it, skip:
            if let end = repeatEndDate,
               calendar.compare(day, to: end, toGranularity: .day) == .orderedDescending {
              return false
            }

            // 1) If `day` is before start, skip
            let cmp = calendar.compare(day, to: start, toGranularity: .day)
            guard cmp != .orderedAscending else { return false }

        switch recurrence {
        case .none:
          // only on the exact same calendar day
          return calendar.isDate(day, inSameDayAs: start)

        case .daily:
          // every day at or after start
          return true

        case .weekly:
          // same weekday
          let wd0 = calendar.component(.weekday, from: start)
          let wd1 = calendar.component(.weekday, from: day)
          return wd0 == wd1

        case .monthly:
          // same day-of-month
          let d0 = calendar.component(.day, from: start)
          let d1 = calendar.component(.day, from: day)
          return d0 == d1

        case .yearly:
          // same month & day
          let m0 = calendar.component(.month, from: start)
          let d0 = calendar.component(.day,   from: start)
          let m1 = calendar.component(.month, from: day)
          let d1 = calendar.component(.day,   from: day)
          return m0 == m1 && d0 == d1
        }
      }
}
