//
//  Persistence.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/25/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true, seedSampleData: true)
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false, seedSampleData: Bool = false) {
        container = NSPersistentContainer(name: "Calendar")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            precondition(error == nil, "Core Data store failed: \(error!)")
        }
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        if seedSampleData { Self.seed(in: container.viewContext) }
    }
}

private extension PersistenceController {
    static func seed(in ctx: NSManagedObjectContext) {
        for i in 0..<10 {
            let e = EventItem(context: ctx)
            e.id                 = UUID()
            e.title              = "Sample Event \(i)"
            e.eventDate          = Date().addingTimeInterval(Double(i) * 3_600)
            e.endTime            = nil
            e.details            = "Details \(i)"
            e.colorRawValue      = "blue"
            e.notificationsEnabled = false
            e.repeatFrequency    = 0
        }
        try? ctx.save()
    }
}
