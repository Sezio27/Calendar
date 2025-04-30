//
//  EditEventView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct EditEventView: View {
    let event: EventItem
    /// The exact day cell the user tapped
    let occurrenceDate: Date
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var eventTitle           = ""
    @State private var eventDetails         = ""
    @State private var eventTime            = Date()
    @State private var chosenColor          = EventColor.green
    @State private var chosenRecurrence     = RepeatFrequency.none
    @State private var notificationsEnabled = true
    
    /// Only show the “split vs series” prompt if this is a true future occurrence of a repeating event.
    private var shouldOfferSplit: Bool {
        guard let start = event.eventDate,
              event.recurrence != .none else {
            return false
        }
        return !Calendar.current.isDate(start, inSameDayAs: occurrenceDate)
    }
    
    @State private var showSplitDialog = false
    @State private var showDeleteDialog = false
    
    var body: some View {
        NavigationStack {
            Form {
                EventFormView(
                    eventTitle:           $eventTitle,
                    eventDetails:         $eventDetails,
                    eventTime:            $eventTime,
                    chosenColor:          $chosenColor,
                    chosenRecurrence:     $chosenRecurrence,
                    notificationsEnabled: $notificationsEnabled,
                    sectionTitle:         "Edit Event"
                )
                
                Section {
                    // now just toggles our dialog
                    Button(role: .destructive) {
                        showDeleteDialog = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Event")
                            Spacer()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if shouldOfferSplit {
                            showSplitDialog = true
                        } else {
                            saveEntireSeries()
                        }
                    }
                }
            }
            .confirmationDialog(
                "This is a recurring event. What would you like to update?",
                isPresented: $showSplitDialog
            ) {
                Button("Only This Occurrence") {
                    saveSingleOccurrence()
                }
                Button("Entire Series") {
                    saveEntireSeries()
                }
                Button("Cancel", role: .cancel) { }
            }
            .confirmationDialog(
                "Delete this event?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                // If this is a future occurrence of a repeating item
                if shouldOfferSplit {
                    Button("Only This Occurrence", role: .destructive) {
                        eventViewModel.deleteOccurrence(
                            event: event,
                            on: occurrenceDate
                        )
                        dismiss()
                    }
                    Button("Entire Series", role: .destructive) {
                        eventViewModel.deleteEvent(event: event)
                        dismiss()
                    }
                } else {
                    // Not a future occurrence (one‐off or start date)
                    Button("Delete Event", role: .destructive) {
                        eventViewModel.deleteEvent(event: event)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .onAppear {
                // populate the form with existing data
                eventTitle           = event.title ?? ""
                eventDetails         = event.details ?? ""
                eventTime            = event.eventDate ?? occurrenceDate
                chosenColor          = event.eventColor
                chosenRecurrence     = event.recurrence
                notificationsEnabled = event.notificationsEnabled
            }
        }
    }
    
    // MARK: - Actions
    
    /// Update every occurrence (the whole series)
    private func saveEntireSeries() {
        let combined = combine(day: occurrenceDate, time: eventTime)
        eventViewModel.updateEvent(
            event:                event,
            title:                eventTitle.isEmpty ? "Untitled Event" : eventTitle,
            date:                 combined,
            details:              eventDetails,
            color:                chosenColor,
            recurrence:           chosenRecurrence,
            notificationsEnabled: notificationsEnabled
        )
        dismiss()
    }
    
    /// Split the series: only this one occurrence gets the new settings
    private func saveSingleOccurrence() {
        let combined = combine(day: occurrenceDate, time: eventTime)
        eventViewModel.splitEvent(
            original:               event,
            occurrenceDate:         combined,
            newRecurrence:          chosenRecurrence,
            notificationsEnabled:   notificationsEnabled,
            newTitle:               eventTitle.isEmpty ? "Untitled Event" : eventTitle,
            newDetails:             eventDetails,
            newColor:               chosenColor
        )
        dismiss()
    }
}
