//
//  EventItem+EndTime.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

import Foundation
import CoreData

extension EventItem {
    
    var effectiveEndTime: Date? {
        endTime ?? eventDate
    }
    func hasFinished(on occurrenceDate: Date, relativeTo now: Date = Date()) -> Bool {
        let effective = endTime ?? occurrenceDate
        return now > effective
    }
}
