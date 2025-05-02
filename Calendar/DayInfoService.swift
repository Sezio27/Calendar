//
//  DayInfoService.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/1/25.
//

import Foundation
import CoreData

actor DayInfoService {
    static let shared = DayInfoService()

    private let ctx = PersistenceController.shared.container.viewContext
    private let base = "https://api.kalendarium.dk/Dayinfo/"

    // main entry-point
    func info(for date: Date) async -> DayInfoItem? {
        if let cached = try? cachedItem(for: date) {
            return cached
        }

        // API contains data only up to "today"
        guard Calendar.current.isDate(date, inSameDayAs: Date())
           || date < Date()
        else { return nil }                      // future → no call

        do {
            let dto   = try await fetchRemote(date)
            return try await importIntoCoreData(dto)
        } catch {
            print("DayInfoService:", error)
            return nil
        }
    }

    // ----------------------------------------------------------------
    private func cachedItem(for day: Date) throws -> DayInfoItem? {
        let start = Calendar.current.startOfDay(for: day)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        let req: NSFetchRequest<DayInfoItem> = DayInfoItem.fetchRequest()
        req.predicate = NSPredicate(
            format: "date >= %@ AND date < %@", start as CVarArg, end as CVarArg
        )
        req.fetchLimit = 1
        return try ctx.fetch(req).first
    }

    private func fetchRemote(_ day: Date) async throws -> DayInfoDTO {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd-MM-yyyy"            // “01-01-2025”
        let url = URL(string: base + fmt.string(from: day))!

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DayInfoDTO.self, from: data)
    }


    private func importIntoCoreData(_ dto: DayInfoDTO) async throws -> DayInfoItem? {
        guard let parsedDate = APIDate.yyyyMMdd.date(from: dto.date) else { return nil }
        
        let item      = DayInfoItem(context: ctx)
        item.date     = parsedDate
        item.sunrise  = dto.astronomy.sunrise
        item.sunset   = dto.astronomy.sunset
        if let span = dto.weather.summary.first(where: { $0.parameter == "Temperatur" }) {
            // "5-9" or "7.0 °C" → take the range part
            let comps = span.summaryValue.split(separator: "-")
            if comps.count == 2 {
                item.tempMin = Double(comps[0].replacingOccurrences(of: ",", with: ".")) ?? 0
                item.tempMax = Double(comps[1]) ?? 0
            }
        }

        try ctx.save()
        return item
    }
}
