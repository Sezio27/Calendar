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
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isGranted = false
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner]
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
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
    
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: localNotification.dateComponents,
            repeats: localNotification.repeats
        )
        
        let request = UNNotificationRequest(
            identifier: localNotification.identifier,
            content: content, trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    func removePendingNotification(identifier: String) {
           notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
       }
    
}
