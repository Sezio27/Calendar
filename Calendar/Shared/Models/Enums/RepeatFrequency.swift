//
//  RepeatFrequency.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/29/25.
//

import Foundation
import CoreData

/// Describes how often an event should repeat.
enum RepeatFrequency: Int16, CaseIterable, Identifiable {
    case none = 0, daily = 1, weekly = 2, monthly = 3, yearly = 4

    var id: Self { self }

    /// User‐facing label in your Picker
    var displayName: String {
        switch self {
        case .none:    return "Never"
        case .daily:   return "Daily"
        case .weekly:  return "Weekly"
        case .monthly: return "Monthly"
        case .yearly:  return "Yearly"
        }
    }
}
