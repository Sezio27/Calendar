//
//  MonthYearPickerView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Select Month and Year", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .accessibilityIdentifier("monthYearPicker")
                Spacer()
            }
            .navigationTitle("Select Month")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }.accessibilityIdentifier("doneMonthPickerButton")
                }
            }
        }
    }
}

#Preview {
    MonthYearPickerView(selectedDate: .constant(Date()), isPresented: .constant(true))
}
