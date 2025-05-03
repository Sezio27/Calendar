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
                
                CalendarHeaderView(
                    displayedDate: displayedDate,
                    isMonthView: isMonthView,
                    onToggleViewMode: {
                        withAnimation { isMonthView.toggle() }
                    },
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
                    },
                    onSettings: {
                        notificationManager.openSettings()
                    }
                )
                
                
                Divider()
                    .padding(.horizontal)
                    .padding(.top, 6)
                
                
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
                
                //delete all button - just for developing testing purposes
                Button(role: .destructive) {
                    eventViewModel.deleteAllEvents()
                } label: {
                    Label("Delete All Events", systemImage: "trash")
                        .foregroundColor(.red)
                        .font(.caption2)
                        .padding()
                }
            }
            
            .navigationDestination(for: Date.self) { date in
                DayView(day: date)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

