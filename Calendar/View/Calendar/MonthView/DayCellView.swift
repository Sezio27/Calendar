//
//  DayCellView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct DayCellView: View {
    let date: Date
    let calendar: Calendar
    let today: Date
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var holiday: HolidayItem?
    
    var events: [EventItem] {
        eventViewModel.eventsForDay(date, using: calendar)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 3) {
            Text("\(calendar.component(.day, from: date))")
                .font(calendar.isDate(date, inSameDayAs: today) ? .headline : .body)
                .frame(maxWidth: .infinity, alignment: .top)
                .frame(height: 20, alignment: .top)
            
            if !events.isEmpty {
                VStack(alignment: .leading, spacing: 1) {
                        if events.count <= 2 {
                            // 1 or 2 events: show each
                            ForEach(events, id: \.self) { event in
                                EventBoxView(event: event, occurrenceDate: date)
                            }
                        } else {
                            // 3+ events: show first + badge
                            EventBoxView(event: events[0], occurrenceDate: date)
                            Text("+\(events.count - 1) more")
                            
                                .font(.system(size: 10))
                                      .foregroundColor(.secondary)
                                      .padding(.top, 2)
                                      .lineLimit(1)             // force a single line
                                      .truncationMode(.tail)    // if it overflows
                                      .minimumScaleFactor(0.6)  // optional: shrink text to fit
                        }
                    
                    }
            }
            Spacer()
            if let holiday = holiday {
                Text(holiday.title?.softHyphenated() ?? "")
                    .font(.system(size: 9))
                    .foregroundColor(.green)
                    .lineLimit(2)                    // allow wrap
                    .minimumScaleFactor(0.7)
                    .padding(.top, 2)
            }
            
          
        }
        .padding(4)
        .frame(minHeight: 80, alignment: .top)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .leading) {                    // pin overlay to the left edge
            Rectangle()
                .fill(.green.opacity(holiday == nil ? 0 : 0.4))
                .frame(width: 2)                           // thickness of the bar
        }
        .task(id: date) {
                    holiday = await eventViewModel.holidayForDay(date)
                }
        
    }
}





