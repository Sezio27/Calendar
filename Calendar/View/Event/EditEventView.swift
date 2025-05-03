//
//  EditEventView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

struct EditEventView: View {
    @ObservedObject var event: EventItem
    let occurrenceDate: Date
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var eventTitle           = ""
    @State private var eventDetails         = ""
    @State private var eventTime            = Date()
    @State private var chosenColor          = EventColor.green
    @State private var chosenRecurrence     = RepeatFrequency.none
    @State private var notificationsEnabled = true
    @State private var endTime          : Date?
    
    init(event: EventItem, occurrenceDate: Date) {
            self._event            = ObservedObject(initialValue: event)
            self.occurrenceDate    = occurrenceDate

            _eventTitle            = State(initialValue: event.title ?? "")
            _eventDetails          = State(initialValue: event.details ?? "")
            _eventTime             = State(initialValue: event.eventDate ?? Date())
            _endTime               = State(initialValue: event.endTime)
            _chosenColor           = State(initialValue: event.eventColor)
            _chosenRecurrence      = State(initialValue: event.recurrence)
        _notificationsEnabled       = State(initialValue: event.notificationsEnabled)
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
                    endTime:              $endTime,
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
                        if event.shouldOfferSplit {
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
                DeleteEventDialogView(
                    event: event,
                    occurrenceDate: occurrenceDate,
                    eventViewModel: eventViewModel,
                    onDeleted: { dismiss() },
                    onCancel: { showDeleteDialog = false }
                )
            }
            .onAppear {
                eventTitle           = event.title ?? ""
                eventDetails         = event.details ?? ""
                eventTime            = event.eventDate ?? occurrenceDate
                chosenColor          = event.eventColor
                chosenRecurrence     = event.recurrence
                notificationsEnabled = event.notificationsEnabled
            }
        }
    }
    
    private func saveEntireSeries() {
        // Take the current master start date's day
           let originalStartDate = event.eventDate ?? occurrenceDate

           // Replace its hour/minute with the new selected time
           let newStart = combine(day: originalStartDate, time: eventTime)
        
        eventViewModel.updateEvent(
            event:                event,
            title:                eventTitle.isEmpty ? "Untitled Event" : eventTitle,
            time:                 newStart,
            endTime:              endTime,
            details:              eventDetails,
            color:                chosenColor,
            recurrence:           chosenRecurrence,
            notificationsEnabled: notificationsEnabled
        )
        dismiss()
    }
    
    private func saveSingleOccurrence() {
        let combined = combine(day: occurrenceDate, time: eventTime)
        eventViewModel.splitEvent(
            original:               event,
            occurrenceDate:         combined,
          
            notificationsEnabled:   notificationsEnabled,
            newTitle:               eventTitle.isEmpty ? "Untitled Event" : eventTitle,
            newDetails:             eventDetails,
            newColor:               chosenColor,
            newEndTime:             endTime
        )
        dismiss()
    }
}
