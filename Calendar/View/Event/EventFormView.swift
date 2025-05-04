//
//  EventFormView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/27/25.
//

//  EventFormView.swift  (complete, warning-free & bug-free)
import SwiftUI

struct EventFormView: View {
    @Binding var eventTitle          : String
    @Binding var eventDetails        : String
    @Binding var eventTime           : Date
    @Binding var endTime             : Date?
    @Binding var chosenColor         : EventColor
    @Binding var chosenRecurrence    : RepeatFrequency
    @Binding var notificationsEnabled: Bool

    let sectionTitle: String

    private var hasEndTime: Binding<Bool> {
        Binding<Bool>(
            get: { endTime != nil },
            set: { want in
                if want {
                    if endTime == nil {
                        endTime = Calendar.current.date(byAdding: .hour,
                                                        value: 1,
                                                        to: eventTime)
                    }
                } else {
                    endTime = nil
                }
            }
        )
    }

    var body: some View {
        Section(header: Text(sectionTitle)) {

            TextField("Title", text: $eventTitle).accessibilityIdentifier("eventTitleField")
            TextEditor(text: $eventDetails)
                .frame(height: 100)
                .accessibilityIdentifier("eventDetailsField")

            DatePicker("Start time",
                       selection: $eventTime,
                       displayedComponents: .hourAndMinute)
            .accessibilityIdentifier("startTimePicker")
            .onChange(of: eventTime) { _, newStart in
                    if let end = endTime, end <= newStart {
                        endTime = Calendar.current.date(byAdding: .minute,
                                                        value: 1,
                                                        to: newStart)
                    }
                }

            if !hasEndTime.wrappedValue {
                Toggle("Add end time", isOn: hasEndTime)
                    .accessibilityIdentifier("addEndTimeToggle")
                    .toggleStyle(.switch)
            }
            
            if hasEndTime.wrappedValue {
                DatePicker("End time",
                           selection: Binding(
                               get: { endTime ?? eventTime },
                               set: { endTime = $0 }
                           ),
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("endTimePicker")
                    .onChange(of: endTime) { _, newEnd in
                            if let end = newEnd, end <= eventTime {
                                endTime = Calendar.current.date(byAdding: .minute,
                                                                value: 1,
                                                                to: eventTime)
                            }
                        }

                Button(role: .destructive) {
                    hasEndTime.wrappedValue = false
                } label: {
                    Label("Remove end time", systemImage: "trash")
                }
                .font(.caption)
                .accessibilityIdentifier("removeEndTimeButton")
            }

            Picker("Event Color", selection: $chosenColor) {
                ForEach(EventColor.allCases, id: \.self) {
                    Text($0.displayName).tag($0)
                }
            }.accessibilityIdentifier("colorPicker")
            
            Picker("Repeat", selection: $chosenRecurrence) {
                ForEach(RepeatFrequency.allCases) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("recurrencePicker")

            Toggle("Notification", isOn: $notificationsEnabled)
                .accessibilityIdentifier("notificationsToggle")
        }
    }
}

