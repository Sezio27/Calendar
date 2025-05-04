//
//  AppBootStrapper.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//
import Foundation

struct AppBootStrapper {
    static func startAllServices() {
        Task.detached {
            let cal  = Calendar.current
            let now  = Date()
            let y0   = cal.component(.year, from:  now)
            let y1   = y0 + 1
            await HolidayService.shared.preload(year: y0)
            await HolidayService.shared.preload(year: y1)
        }
    }
}
