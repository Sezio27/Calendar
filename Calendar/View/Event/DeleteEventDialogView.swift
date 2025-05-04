//
//  DeleteEventDialogView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/2/25.
//

import SwiftUI

struct DeleteEventDialogView: View {
    @ObservedObject var event: EventItem
    let occurrenceDate: Date
    let eventViewModel: EventViewModel
    let onDeleted: () -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            if event.shouldOfferSplit {
                Button("Only This Occurrence", role: .destructive) {
                    eventViewModel.deleteOccurrence(event: event, on: occurrenceDate)
                    onDeleted()
                }.accessibilityIdentifier("deleteOccurrenceButton")
                Button("Entire Series", role: .destructive) {
                    eventViewModel.deleteEvent(event: event)
                    onDeleted()
                }.accessibilityIdentifier("deleteSeriesButton")
            } else {
                Button("Delete Event", role: .destructive) {
                    eventViewModel.deleteEvent(event: event)
                    onDeleted()
                }.accessibilityIdentifier("deleteSingleButton")
            }
            Button("Cancel", role: .cancel) { onCancel() }.accessibilityIdentifier("cancelDeleteButton")
        }
    }
}

