//
//  DayEventsView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct DayView: View {
    let day: Date
    @EnvironmentObject private var eventViewModel: EventViewModel
    @State private var dayInfo: DayInfoItem? = nil

    var body: some View {
        VStack {
            DayInformationView(date: day)
            EventListView(day: day)
        }
        .navigationTitle("\(day.formatted(date: .long, time: .omitted))")
        .task {
            dayInfo = await eventViewModel.dayInfoForDate(day)
        }
    }
}


