//
//  TestCoreData.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import CoreData

extension NSManagedObjectContext {
    /// Shortcut to our in-memory test context
    static var test: NSManagedObjectContext {
        MockPersistenceController.shared.viewContext
    }
}
