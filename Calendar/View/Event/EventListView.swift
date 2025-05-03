import SwiftUI

struct EventListView: View {
    /// The day whose events we’re showing
    let day: Date

    @EnvironmentObject var eventViewModel: EventViewModel

    @State private var showingAddSheet   = false
    @State private var selectedEvent     : EventItem? = nil
    @State private var eventToDelete     : EventItem?
    @State private var showDeleteDialog  = false
    @State private var refreshID = UUID()
    
    private let calendar = Calendar.current

    var body: some View {
        VStack {
            let eventsForDay = eventViewModel.eventsForDay(day, using: calendar)

            if eventsForDay.isEmpty {
                Text("No events for \(day.formatted(date: .long, time: .omitted))")
                    .padding()
            } else {
                List {
                    ForEach(eventsForDay, id: \.objectID) { event in
                        EventRowView(selectedEvent: $selectedEvent, event: event)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    eventToDelete    = event
                                    showDeleteDialog = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete { idxs in
                        let evs = eventsForDay
                        if let idx = idxs.first {
                            eventToDelete    = evs[idx]
                            showDeleteDialog = true
                        }
                    }
                }
                .id(refreshID)
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
                .onDisappear {
                            refreshID = UUID()
                        }
        }

        .confirmationDialog(
            "Delete this event?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            if let event = eventToDelete {
                DeleteEventDialogView(
                    event: event,
                    occurrenceDate: day,
                    eventViewModel: eventViewModel,
                    onDeleted: { showDeleteDialog = false },
                    onCancel: { showDeleteDialog = false }
                )
            }
        }
    }
}
