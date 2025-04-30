//
//  ContentView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/25/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var displayedDate: Date = Date()
    @State private var showMonthPicker: Bool = false
    @State private var isMonthView = true
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @Environment(\.scenePhase) var scenePhase
    
    
    private let calendar = Calendar.current
    private let today = Date()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        withAnimation { isMonthView.toggle() }
                    } label: {
                        Image(systemName: isMonthView ? "list.bullet" : "calendar")
                            .font(.title2)
                    }
                    .fixedSize()
                    
                    
                    
                    CalendarHeaderView(
                        displayedDate: displayedDate,
                        onPrevious: {
                            if let previous = calendar.date(byAdding: .month, value: -1, to: displayedDate) {
                                displayedDate = previous
                            }
                        },
                        onNext: {
                            if let next = calendar.date(byAdding: .month, value: 1, to: displayedDate) {
                                displayedDate = next
                            }
                        },
                        onSelectDate: {
                            showMonthPicker.toggle()
                        }
                    )
                    
                    .frame(maxWidth: .infinity,alignment: .center)
                    
                    Button {
                        // e.g. open your app settings
                        notificationManager.openSettings()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }
                    .fixedSize()
                }
                
                .padding(.horizontal)
                .padding(.top, 28)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                Divider()
                    .padding(.horizontal)
                    .padding(.top)
                
                
                if isMonthView {
                    WeekdayHeaderView(weekDays: calendar.shortWeekdaySymbols)
                    
                    CalendarGridView(
                        displayedMonth: displayedDate,
                        calendar: calendar,
                        today: today
                    )
                } else {
                    WeekView(
                      selectedDate: displayedDate,
                      calendar:      calendar
                    ) { newDate in
                      displayedDate = newDate
                    }
                    
                    
                }
                Spacer()
                
            }
            
            .navigationDestination(for: Date.self) { date in
                DayEventsView(day: date)
            }
            .sheet(isPresented: $showMonthPicker) {
                MonthYearPickerView(selectedDate: $displayedDate, isPresented: $showMonthPicker)
            }
        }
        
        .task {
            try? await notificationManager.requestAuthorization()
        }.onChange(of: scenePhase) {
            if scenePhase == .active {
                Task { await notificationManager.getCurrentSettings() }
            }
        }
    }
    
    private func daysInMonth(for date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func firstWeekdayOfMonth(for date: Date) -> Int {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return 1 }
        return calendar.component(.weekday, from: startOfMonth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

