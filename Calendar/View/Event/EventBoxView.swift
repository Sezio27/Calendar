//
//  EventTitleBox.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//
import SwiftUI

struct EventBoxView: View {
    @ObservedObject var event: EventItem
    let occurrenceDate: Date
    
    var body: some View {
        Text(event.title ?? "Untitled")
            .font(.system(size: 10))
            .padding(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(event.eventColor.swiftUIColor)
                    .opacity(event.hasFinished(on: occurrenceDate) ? 0.7 : 1)
            )
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

