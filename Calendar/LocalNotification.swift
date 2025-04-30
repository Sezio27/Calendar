//
//  LocalNotification.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/25/25.
//

import Foundation

struct LocalNotification {
    var identifier: String
    var title: String
    var body: String
    var dateComponents: DateComponents
    var repeats: Bool
}
