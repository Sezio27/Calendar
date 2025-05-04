//
//  NotificationManager.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/25/25.
//

import Foundation
import NotificationCenter

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    private let center: NotificationCenterProtocol
    @Published var isGranted = false
    
    init(center: NotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.center = center
        super.init()
        
        if let real = center as? UNUserNotificationCenter {
            real.delegate = self
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner]
    }
    
    func requestAuthorization() async throws {
        try await (center as! UNUserNotificationCenter)
            .requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let settings = await (center as! UNUserNotificationCenter).notificationSettings()
        isGranted = (settings.authorizationStatus == .authorized)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func scheduleNotification(event: EventItem) async {
        guard
            event.notificationsEnabled,
            let id   = event.id?.uuidString,
            let date = event.eventDate
        else { return }
        
        let (components, repeats) = makeTriggerComponents(
            for: date,
            frequency: event.recurrence
        )
        
        let request = buildRequest(
            identifier:     id,
            title:          event.title ?? "Event Reminder",
            body:           event.details ?? "",
            dateComponents: components,
            repeats:        repeats
        )
        
        try? await center.add(request)
    }
    
    
    func removePendingNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func buildRequest(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats:      repeats
        )
        
        return UNNotificationRequest(
            identifier:  identifier,
            content:     content,
            trigger:     trigger
        )
    }
    
    private func makeTriggerComponents(
        for date: Date,
        frequency: RepeatFrequency
    ) -> (DateComponents, Bool) {
        switch frequency {
        case .none:
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            return (comps, false)
        case .daily:
            let comps = Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )
            return (comps, true)
        case .weekly:
            let comps = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: date
            )
            return (comps, true)
        case .monthly:
            let comps = Calendar.current.dateComponents(
                [.day, .hour, .minute],
                from: date
            )
            return (comps, true)
        case .yearly:
            let comps = Calendar.current.dateComponents(
                [.month, .day, .hour, .minute],
                from: date
            )
            return (comps, true)
        }
    }
    
}

protocol NotificationCenterProtocol {
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}


extension UNUserNotificationCenter: NotificationCenterProtocol {}
