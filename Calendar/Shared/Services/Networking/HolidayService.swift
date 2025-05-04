//
//  HolidayService.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/30/25.
//

import Foundation
import CoreData

actor HolidayService {
    static let shared = HolidayService()
    
    private let calendar = Calendar(identifier: .gregorian)
    private let ctx: NSManagedObjectContext
    private let baseURL  = "https://api.kalendarium.dk/MinimalCalendar/"
    
    init(context: NSManagedObjectContext =
               PersistenceController.shared.container.viewContext) {
            self.ctx = context
        }
    
    func info(for day: Date) async -> HolidayItem? {
        let start = Calendar.current.startOfDay(for: day)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        let req: NSFetchRequest<HolidayItem> = HolidayItem.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            start as CVarArg, end as CVarArg
        )
        
        return try? ctx.fetch(req).first
    }
    
    func preload(year: Int) async {
        do {
            guard try await isMissing(year: year) else { return }
            let data = try await fetchRemote(year: year)
            try await importIntoCoreData(days: data.days, year: year)
        } catch {
            print("HolidayService error:", error)
        }
    }
    
    private func isMissing(year: Int) async throws -> Bool {
        let req: NSFetchRequest<HolidayItem> = HolidayItem.fetchRequest()
        req.predicate = NSPredicate(format: "year == %d", year)
        let count = try ctx.count(for: req)
        return count == 0
    }
    
    private func fetchRemote(year: Int) async throws -> YearResponse {
        let url = URL(string: baseURL + "\(year)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(YearResponse.self, from: data)
    }
    
    
    private func importIntoCoreData(days: [DayDTO], year: Int) async throws {
        for day in days {
            guard
                let date = APIDate.yyyyMMdd.date(from: day.date),
                let ev   = day.events.first(where: { $0.holliday })
            else { continue }
            
            let item      = HolidayItem(context: ctx)
            item.id       = UUID()
            item.date     = date
            item.title    = ev.danishShort
            item.year     = Int16(year)
        }
        try ctx.save()
    }
}
