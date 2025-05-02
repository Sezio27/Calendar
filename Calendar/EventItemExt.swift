//
//  EventItemExt.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import Foundation
import CoreData

extension EventItem {
    
    var effectiveEndTime: Date? {
        endTime ?? eventDate
    }
    func hasFinished(relativeTo now: Date = Date()) -> Bool {
        guard let finish = effectiveEndTime else { return false }
        return now > finish
    }
    var eventColor: EventColor {
        get {
            guard let raw = colorRawValue, let ec = EventColor(rawValue: raw) else {
                return .blue
            }
            return ec
        }
        set {
            colorRawValue = newValue.rawValue
        }
    }
}




