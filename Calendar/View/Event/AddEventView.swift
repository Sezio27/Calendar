//
//  AddEditEventView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct AddEventView: View {
    let day: Date
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var eventTitle: String = ""
    @State private var eventDetails: String = ""
    @State private var eventTime: Date = Date()
    @State private var chosenColor: EventColor = .green
    @State private var chosenRecurrence: RepeatFrequency = .none
    @State private var notificationsEnabled = true
    @State private var endTime: Date?  = nil
    
    var body: some View {
        NavigationStack {
            Form {
                EventFormView(eventTitle: $eventTitle,
                              eventDetails: $eventDetails,
                              eventTime: $eventTime,
                              endTime: $endTime,
                              chosenColor: $chosenColor,
                              chosenRecurrence: $chosenRecurrence,
                              notificationsEnabled: $notificationsEnabled,
                              sectionTitle: "Add Event")
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }.accessibilityIdentifier("cancelAddButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        
                        let combinedDate = combine(day: day, time: eventTime)
                        eventViewModel.addEvent(
                            title: eventTitle.isEmpty ? "Untitled Event" : eventTitle,
                            date: combinedDate,
                            endTime: endTime,
                            details: eventDetails,
                            color: chosenColor,
                            recurrence: chosenRecurrence,
                            notificationsEnabled: notificationsEnabled
                        )
                        dismiss()
                    }.accessibilityIdentifier("saveEventButton")
                }
            }
        }
    }
}


