//
//  DayEventsView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct DayView: View {
    let day: Date
    @State private var dayInfo: DayInfoItem? = nil

    var body: some View {
        VStack {
            DayInformationView(date: day)
            EventListView(day: day)
        }
        .navigationTitle("\(day, formatter: dayFormatter)")
        .task {
            dayInfo = await DayInfoService.shared.info(for: day)
        }
    }
}

private let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    return f
}()
