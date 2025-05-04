//
//  APIDate.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/1/25.
//

import Foundation

enum APIDate {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.locale   = .init(identifier: "en_US_POSIX")
        f.timeZone = .init(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static let ddMMyyyy: DateFormatter = {
        let f = yyyyMMdd
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()
}
