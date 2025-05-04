//
//  CalendarHeaderView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//
import SwiftUI

struct CalendarHeaderView: View {
    let displayedDate: Date
    let isMonthView: Bool
    let onToggleViewMode: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSelectDate: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack {
            Button {
                onToggleViewMode()
            } label: {
                Image(systemName: isMonthView ? "list.bullet" : "calendar")
                    .font(.title2)
            }
            .accessibilityIdentifier("toggleViewModeButton")
            .fixedSize()
            
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }.accessibilityIdentifier("prevMonthButton")
                
                Button(action: onSelectDate) {
                    Text(displayedDate.monthYearString())
                        .font(.title2)
                        .fontWeight(.bold)
                }.accessibilityIdentifier("monthPickerButton")
                
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }.accessibilityIdentifier("nextMonthButton")
            } .frame(maxWidth: .infinity,alignment: .center)

        

            Button {
                onSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }.accessibilityIdentifier("settingsButton")
            .fixedSize()
        }
        .padding(.horizontal)
        .padding(.top, 28)
        .frame(height: 54)
        .frame(maxWidth: .infinity)
    }

}




