//
//  CalendarHeaderView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//
import SwiftUI

struct CalendarHeaderView: View {
    let displayedDate: Date
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSelectDate: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Button(action: onSelectDate) {
                Text(monthYearString(for: displayedDate))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}



