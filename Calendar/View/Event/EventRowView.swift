//
//  EventRowView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

import SwiftUI

struct EventRowView: View {
    @Binding var selectedEvent: EventItem?
    let event: EventItem
    let occurrenceDate: Date
    
    var body: some View {
        HStack {
            Circle()
                .fill(event.eventColor.swiftUIColor)
                .opacity(event.hasFinished(on: occurrenceDate) ? 0.7 : 1)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text(event.title ?? "Untitled")
                    .font(.headline)
                Text(event.details ?? "")
                    .font(.subheadline)
                HStack {
                    if let start = event.eventDate {
                        Text("Starts: \(start.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                    }
                    if let end = event.endTime {
                        
                        Text("Ends: \(end.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                    }
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedEvent = event
        }
        .padding(.vertical, 8)
    }
}
