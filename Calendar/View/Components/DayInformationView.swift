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
    let date: Date
    var calendar: Calendar = .current
    
    @EnvironmentObject private var eventViewModel: EventViewModel
    @State             private var dayInfo: DayInfoItem? = nil
    @State             private var holiday: HolidayItem? = nil
    
    var body: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            VStack(spacing: 6) {
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
                
                if let h = holiday {
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
        .task(id: date) {
            async let info  = eventViewModel.dayInfoForDate(date)
            async let hol   = eventViewModel.holidayForDay(date)
            
            dayInfo = await info
            holiday = await hol
        }
    }
}
