//
//  MockPersistenceController.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import CoreData
@testable import Calendar

enum MockPersistenceController {
    static let shared: NSPersistentContainer = {
        PersistenceController(inMemory: true).container
    }()
}
