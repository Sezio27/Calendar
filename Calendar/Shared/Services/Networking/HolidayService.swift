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
    private let ctx      = PersistenceController.shared.container.viewContext
    private let baseURL  = "https://api.kalendarium.dk/MinimalCalendar/"

    /// Ensures ‹year› (and only if missing) is present in Core Data.
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
