//
//  EventFormView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/27/25.
//

//  EventFormView.swift  (complete, warning-free & bug-free)
import SwiftUI

struct EventFormView: View {
    // MARK: bindings passed in
    @Binding var eventTitle          : String
    @Binding var eventDetails        : String
    @Binding var eventTime           : Date
    @Binding var endTime             : Date?          // optional binding
    @Binding var chosenColor         : EventColor
    @Binding var chosenRecurrence    : RepeatFrequency
    @Binding var notificationsEnabled: Bool

    let sectionTitle: String

    // MARK: derived binding — drives the toggle and picker visibility
    private var hasEndTime: Binding<Bool> {
        Binding<Bool>(
            get: { endTime != nil },
            set: { want in
                if want {
                    // when user flips toggle ON and we have no endTime, initialise it
                    if endTime == nil {
                        endTime = Calendar.current.date(byAdding: .hour,
                                                        value: 1,
                                                        to: eventTime)
                    }
                } else {
                    // user turned it OFF → clear endTime
                    endTime = nil
                }
            }
        )
    }

    var body: some View {
        Section(header: Text(sectionTitle)) {

            // title & details
            TextField("Title", text: $eventTitle)
            TextEditor(text: $eventDetails)
                .frame(height: 100)

            // start time (always)
            DatePicker("Start time",
                       selection: $eventTime,
                       displayedComponents: .hourAndMinute)
            .onChange(of: eventTime) { _, newStart in
                    if let end = endTime, end <= newStart {
                        endTime = Calendar.current.date(byAdding: .minute,
                                                        value: 1,
                                                        to: newStart)
                    }
                }

            // toggle visible only when there is *not* an end time yet
            if !hasEndTime.wrappedValue {
                Toggle("Add end time", isOn: hasEndTime)
                    .toggleStyle(.switch)
            }

            // picker visible whenever hasEndTime == true
            if hasEndTime.wrappedValue {
                DatePicker("End time",
                           selection: Binding(
                               get: { endTime ?? eventTime },
                               set: { endTime = $0 }
                           ),
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .onChange(of: endTime) { _, newEnd in
                            if let end = newEnd, end <= eventTime {
                                endTime = Calendar.current.date(byAdding: .minute,
                                                                value: 1,
                                                                to: eventTime)
                            }
                        }

                Button(role: .destructive) {
                    hasEndTime.wrappedValue = false   // clears endTime
                } label: {
                    Label("Remove end time", systemImage: "trash")
                }
                .font(.caption)
            }

            // colour
            Picker("Event Color", selection: $chosenColor) {
                ForEach(EventColor.allCases, id: \.self) {
                    Text($0.displayName).tag($0)
                }
            }

            // repeat
            Picker("Repeat", selection: $chosenRecurrence) {
                ForEach(RepeatFrequency.allCases) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)

            // notifications
            Toggle("Notification", isOn: $notificationsEnabled)
        }
    }
}

