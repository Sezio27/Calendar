//
//  WeekDayHeaderView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct WeekdayHeaderView: View {
    let weekDays: [String]
    
    var body: some View {
        HStack {
            // Week number label
            Text("Wk")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 24)
                
                
            
            // Weekday labels
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom)
    }
}

#Preview {
    let calendar = Calendar.current
    WeekdayHeaderView(weekDays: calendar.shortWeekdaySymbols)
}
