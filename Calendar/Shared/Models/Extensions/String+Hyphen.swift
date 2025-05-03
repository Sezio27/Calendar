//
//  String+Hyphen.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

import Foundation

extension String {
    func softHyphenated(breakAfter firstN: Int = 8) -> String {
        guard count > firstN else { return self }
        var chars = Array(self)
        chars.insert("\u{00AD}", at: min(firstN, chars.count - 3))
        return String(chars)
    }
}
