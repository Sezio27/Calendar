//
//  EventTitleBox.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//
import SwiftUI

struct EventTitleBox: View {
    @ObservedObject var event: EventItem
    
    var body: some View {
        Text(event.title ?? "Untitled")
            .font(.system(size: 10))
            .padding(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(event.eventColor.swiftUIColor)
            )
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

