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
    @State private var dayInfo: DayInfoItem? = nil
    @GestureState private var dragOffset: CGFloat = 0 
    
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
    
    private func holiday(for day: Date) -> HolidayItem? {
        eventViewModel.holidayForDay(day, using: calendar)
    }
    
    var body: some View {
        VStack() {
            
            VStack {
                Text(headerDate)
                    .font(.headline)
            }
            .padding(.vertical, 10)
            
            
            weekStrip
            
            
            
            DayInformationView(date: selectedDate)
            
            
            
            
            
            EventListView(day: selectedDate)
        }
        .padding(.horizontal)
        .task(id: Calendar.current.startOfDay(for: selectedDate)) {
            dayInfo = await DayInfoService.shared.info(for: selectedDate)
        }
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
    
    private func softHyphenated(_ text: String, breakAfter firstN: Int = 8) -> String {
        guard text.count > firstN else { return text }
        var chars = Array(text)
        chars.insert("\u{00AD}", at: min(firstN, chars.count - 3))
        return String(chars)
    }
}

private extension WeekView {

    var weekStrip: some View {
        let threshold: CGFloat = 80      // swipe distance to trigger change

        // Entire bar slides horizontally by dragOffset while user drags
        return HStack(spacing: 12) {
            ForEach(weekDates, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

                VStack(spacing: 4) {
                    Text(calendar.shortWeekdaySymbols[
                        calendar.component(.weekday, from: date) - 1])
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("\(calendar.component(.day, from: date))")
                        .font(.body)
                        .foregroundColor(
                            isSelected ? .white
                                       : (calendar.isDate(date,
                                                          equalTo: selectedDate,
                                                          toGranularity: .month)
                                          ? .primary : .secondary)
                        )
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.accentColor : .clear)
                        )
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    if holiday(for: date) != nil {
                        Rectangle()
                            .fill(Color.green.opacity(0.4))
                            .frame(width: 2)
                    }
                }
                .onTapGesture { onDateTap(date) }
            }
        }
        .padding(.bottom, 10)
        .offset(x: dragOffset)                          // ← live follow
        .animation(.interactiveSpring(), value: dragOffset)
        .contentShape(Rectangle())                      // touch anywhere
        .gesture(
            DragGesture()
                // update dragOffset continuously
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                // decide where to land
                .onEnded { value in
                    let dx = value.translation.width
                    if dx < -threshold {
                        // swipe-left → next week
                        if let next = calendar.date(byAdding: .weekOfYear,
                                                    value: 1,
                                                    to: selectedDate) {
                            withAnimation(.spring()) { onDateTap(next) }
                        }
                    } else if dx > threshold {
                        // swipe-right → previous week
                        if let prev = calendar.date(byAdding: .weekOfYear,
                                                    value: -1,
                                                    to: selectedDate) {
                            withAnimation(.spring()) { onDateTap(prev) }
                        }
                    }
                    // No extra work needed to “snap back” if under threshold:
                    // dragOffset animates back to 0 automatically because the
                    // @GestureState resets when the gesture ends.
                }
        )
    }
}
