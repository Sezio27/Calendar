import SwiftUI

struct EventListView: View {
    /// The day whose events we’re showing
    let day: Date

    @EnvironmentObject var eventViewModel: EventViewModel

    @State private var showingAddSheet   = false
    @State private var selectedEvent     : EventItem? = nil

    // for delete confirmation
    @State private var eventToDelete     : EventItem?
    @State private var showDeleteDialog  = false

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            let eventsForDay = eventViewModel.eventsForDay(day, using: calendar)

            if eventsForDay.isEmpty {
                Text("No events for \(day, formatter: dayFormatter)")
                    .padding()
            } else {
                List {
                    ForEach(eventsForDay, id: \.self) { event in
                        EventRow(event: event)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    // queue up the confirmation
                                    eventToDelete    = event
                                    showDeleteDialog = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete { idxs in
                        // Any delete from the list should also confirm
                        let evs = eventsForDay
                        if let idx = idxs.first {
                            eventToDelete    = evs[idx]
                            showDeleteDialog = true
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            Button { showingAddSheet = true } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Event")
                }
            }
            .padding()
            Spacer()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEventView(day: day)
                .environmentObject(eventViewModel)
        }
        .sheet(item: $selectedEvent) { event in
            EditEventView(event: event, occurrenceDate: day)
                .environmentObject(eventViewModel)
        }
        // ----------------------------------------------------------------
        // Delete confirmation dialog
        // ----------------------------------------------------------------
        .confirmationDialog(
            "Delete this event?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            if let event = eventToDelete,
               event.recurrence != .none,
               !calendar.isDate(event.eventDate ?? day, inSameDayAs: day)
            {
                // A future occurrence of a recurring event
                Button("Only This Occurrence", role: .destructive) {
                    eventViewModel.deleteOccurrence(event: event, on: day)
                }
                Button("Entire Series", role: .destructive) {
                    eventViewModel.deleteEvent(event: event)
                }
            } else {
                // A one-off or the master occurrence
                Button("Delete Event", role: .destructive) {
                    if let event = eventToDelete {
                        eventViewModel.deleteEvent(event: event)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    @ViewBuilder
    private func EventRow(event: EventItem) -> some View {
        HStack {
            Circle()
                .fill(event.eventColor.swiftUIColor)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text(event.title ?? "Untitled")
                    .font(.headline)
                Text(event.details ?? "")
                    .font(.subheadline)
                HStack {
                    if let start = event.eventDate {
                        Text("Starts: \(timeString(for: start))")
                            .font(.caption)
                    }
                    if let end = event.endTime {
                        Text("Ends: \(timeString(for: end))")
                            .font(.caption)
                    }
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedEvent = event
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helpers

private let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    return f
}()

private func timeString(for date: Date) -> String {
    let f = DateFormatter()
    f.timeStyle = .short
    return f.string(from: date)
}
