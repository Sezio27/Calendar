//
//  CalendarGridView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject var eventViewModel: EventViewModel

    /// The month we’re displaying (should come from ContentView’s `displayedDate`)
    let displayedMonth: Date
    let calendar: Calendar
    let today: Date

    // 1) Build the full 6×7 grid of Dates (including days before & after the month)
        private var allRows: [[Date]] {
            guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
                return []
            }
            let monthFirst = monthInterval.start

            // How many days to pad before the first?
            let leading = (calendar.component(.weekday, from: monthFirst)
                         - calendar.firstWeekday + 7) % 7

            // Build the array
            var dates: [Date] = []
            // previous-month tail
            for i in (-leading..<0) {
                if let d = calendar.date(byAdding: .day, value: i, to: monthFirst) {
                    dates.append(d)
                }
            }
            // current month
            let monthCount = calendar.range(of: .day, in: .month, for: monthFirst)!.count
            for i in 0..<monthCount {
                if let d = calendar.date(byAdding: .day, value: i, to: monthFirst) {
                    dates.append(d)
                }
            }
            // next-month head to fill 6×7
            let toFill = (6 * 7) - dates.count
            if let last = dates.last {
                for i in 1...toFill {
                    if let d = calendar.date(byAdding: .day, value: i, to: last) {
                        dates.append(d)
                    }
                }
            }

            // chunk into weeks
            return stride(from: 0, to: dates.count, by: 7).map {
                Array(dates[$0..<min($0+7, dates.count)])
            }
        }

        // 2) Filter out any week-row that has *no* date in the displayed month
        private var rows: [[Date]] {
            allRows.filter { week in
                week.contains {
                    calendar.isDate($0, equalTo: displayedMonth, toGranularity: .month)
                }
            }
        }
    
    private var columns: [GridItem] {
            [ GridItem(.fixed(24)) ]
            + Array(repeating: .init(.flexible()), count: 7)
        }
    
    var body: some View {

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(rows.indices, id: \.self) { row in
                    let week = rows[row]

                    // Week number for this row
                    let weekNum = calendar.component(.weekOfYear, from: week[0])
                    VStack {
                        Text("\(weekNum)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                           
                       Spacer()
                    }
                    .padding(.top, 6)
                    .frame(minHeight: 80)
                   
                    // Each day cell
                    ForEach(week, id: \.self) { date in
                        let isInMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)

                        NavigationLink(value: date) {
                            DayCellView(
                                date: date,
                                calendar: calendar,
                                today: today
                            )
                            // Dim out-of-month days
                            .foregroundColor(isInMonth ? .primary : .secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            
        
    }
}
