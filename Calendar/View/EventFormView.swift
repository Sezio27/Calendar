//
//  EventFormView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/27/25.
//

import SwiftUI

struct EventFormView: View {
    @Binding var eventTitle: String
    @Binding var eventDetails: String
    @Binding var eventTime: Date
    @Binding var chosenColor: EventColor
    @Binding var chosenRecurrence: RepeatFrequency
    @Binding var notificationsEnabled: Bool
   
    let sectionTitle: String
    
    var body: some View {
        Section(header: Text(sectionTitle)) {
            TextField("Title", text: $eventTitle)
            TextEditor(text: $eventDetails)
                .frame(height: 100)
            DatePicker("Time", selection: $eventTime, displayedComponents: .hourAndMinute)
            
            Picker("Event Color", selection: $chosenColor) {
                ForEach(EventColor.allCases, id: \.self) { colorCase in
                    Text(colorCase.displayName)
                        .tag(colorCase)
                }
            }
            Picker("Repeat", selection: $chosenRecurrence) {
              ForEach(RepeatFrequency.allCases) { freq in
                Text(freq.displayName).tag(freq)
              }
            }.pickerStyle(.menu)
            Toggle("Notification", isOn: $notificationsEnabled)
        }
    }
}
