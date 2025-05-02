//
//  DayInformationView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/1/25.
//

//
//  InformationView.swift
//
import SwiftUI

struct DayInformationView: View {
    
    /// Calendar day we’re showing (today, past, or future)
    let date: Date
    /// Which calendar to compare with when fetching holidays
    var calendar: Calendar = .current

    // Core-Data sources
    @EnvironmentObject private var eventViewModel: EventViewModel
    @State            private var dayInfo: DayInfoItem? = nil

    private func holiday(for day: Date) -> HolidayItem? {
        eventViewModel.holidayForDay(day, using: calendar)
    }
    
    var body: some View {
        Group {
            Divider()
                .padding(.horizontal)
            VStack(spacing: 6) {
                // ── Weather block ────────────────────────────────
                Group {
                    if let info = dayInfo {
                        WeatherBlockView(info: info)
                    } else if date < Date() {
                        ProgressView().progressViewStyle(.circular)
                    } else {
                        Text("No weather information available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let h = holiday(for: date) {
                    Text(h.title ?? "")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    
                }
            }
            Divider()
                .padding(.horizontal)
        }
        .padding(.vertical, 6)
        .task(id: Calendar.current.startOfDay(for: date)) {
            // lazy fetch, cached by DayInfoService
            dayInfo = await DayInfoService.shared.info(for: date)
        }
    }
}
