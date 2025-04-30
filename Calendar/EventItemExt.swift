//
//  EventItemExt.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import Foundation
import CoreData

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




