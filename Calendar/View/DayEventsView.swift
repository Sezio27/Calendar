//
//  DayEventsView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct DayEventsView: View {
    let day: Date

    var body: some View {
        EventListView(day: day)
            .navigationTitle("\(day, formatter: dayFormatter)")
    }
}

// bring in the same formatter
private let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    return f
}()
