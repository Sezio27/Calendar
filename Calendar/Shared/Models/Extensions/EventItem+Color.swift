//
//  EventItem+Color.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

extension EventItem {
    
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
