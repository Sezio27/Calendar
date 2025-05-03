//
//  CalendarGridView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject var eventViewModel: EventViewModel

    let displayedMonth: Date
    let calendar: Calendar
    let today: Date

    
        private var allRows: [[Date]] {
            guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
                return []
            }
            let monthFirst = monthInterval.start

            let leading = (calendar.component(.weekday, from: monthFirst)
                         - calendar.firstWeekday + 7) % 7

       
            var dates: [Date] = []

            for i in (-leading..<0) {
                if let d = calendar.date(byAdding: .day, value: i, to: monthFirst) {
                    dates.append(d)
                }
            }
       
            let monthCount = calendar.range(of: .day, in: .month, for: monthFirst)!.count
            for i in 0..<monthCount {
                if let d = calendar.date(byAdding: .day, value: i, to: monthFirst) {
                    dates.append(d)
                }
            }
            
            let toFill = (6 * 7) - dates.count
            if let last = dates.last {
                for i in 1...toFill {
                    if let d = calendar.date(byAdding: .day, value: i, to: last) {
                        dates.append(d)
                    }
                }
            }

            return stride(from: 0, to: dates.count, by: 7).map {
                Array(dates[$0..<min($0+7, dates.count)])
            }
        }

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
                   
                  
                    ForEach(week, id: \.self) { date in
                        let isInMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)

                        NavigationLink(value: date) {
                            DayCellView(
                                date: date,
                                calendar: calendar,
                                today: today
                            )
                         
                            .foregroundColor(isInMonth ? .primary : .secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            
    }
}
