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
    
    // Inject the shared EventViewModel from the environment
    @EnvironmentObject var eventViewModel: EventViewModel
  
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
                                EventTitleBox(event: event)
                            }
                        } else {
                            // 3+ events: show first + badge
                            EventTitleBox(event: events[0])
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
        }
        .padding(4)
        .frame(minHeight: 80, alignment: .top)
        .frame(maxWidth: .infinity)
        
    }
}





