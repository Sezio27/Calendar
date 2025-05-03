//
//  Date+Formatting.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

import Foundation

extension Date {
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self)
    }
}
