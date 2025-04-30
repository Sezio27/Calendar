//
//  WeekView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/29/25.
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var eventViewModel: EventViewModel

    /// The day the user has currently selected
    let selectedDate: Date
    /// Which calendar to use for components, week‐of‐year, etc.
    let calendar: Calendar
    /// Called when the user taps on one of the 7 day cells
    var onDateTap: (Date) -> Void

    @State private var showingAddSheet = false

    /// “Today”, “Yesterday”, “Tomorrow” or weekday name
    private var headerDate: String {
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            let fm = DateFormatter()
            fm.dateFormat = "EEEE"
            return fm.string(from: selectedDate)
        }
    }

    /// The 7 dates in the same week as `selectedDate`
    private var weekDates: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)
        else { return [] }
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }

    /// All events on the selected day
    private var events: [EventItem] {
        eventViewModel.eventsForDay(selectedDate, using: calendar)
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: — Day header
            VStack {
                Text(headerDate)
                    .font(.headline)
            }
            .padding(.vertical)

            // MARK: — Week strip
            HStack(spacing: 12) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    VStack(spacing: 4) {
                        Text(calendar.shortWeekdaySymbols[
                            calendar.component(.weekday, from: date) - 1
                        ])
                        .font(.caption2)
                        .foregroundColor(.secondary)

                        Text("\(calendar.component(.day, from: date))")
                            .font(.body)
                            .foregroundColor(isSelected ? .white
                                                      : (calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                                                         ? .primary
                                                         : .secondary))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(isSelected ? Color.accentColor : Color.clear)
                            )
                    }
                    .frame(maxWidth: .infinity)       // <-- evenly distribute
                    .onTapGesture { onDateTap(date) }
                }
            }

            Divider()

            EventListView(day: selectedDate)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingAddSheet) {
            AddEventView(day: selectedDate)
                .environmentObject(eventViewModel)
        }
    }

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.compactMap { idx in
            events.indices.contains(idx) ? events[idx] : nil
        }
        for event in toDelete {
            eventViewModel.deleteEvent(event: event)
        }
    }
}
