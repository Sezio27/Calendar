//
//  DateUtils.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

// DateUtils.swift
import Foundation

func combine(day: Date, time: Date) -> Date {
    let calendar = Calendar.current
    let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
    var merged = DateComponents()
    merged.year = dayComponents.year
    merged.month = dayComponents.month
    merged.day = dayComponents.day
    merged.hour = timeComponents.hour
    merged.minute = timeComponents.minute
    merged.second = timeComponents.second
    return calendar.date(from: merged) ?? day
}
