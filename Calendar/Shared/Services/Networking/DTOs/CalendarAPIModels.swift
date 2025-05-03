//
//  CalendarAPIModels.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 4/30/25.
//

struct YearResponse: Decodable {
    let days: [DayDTO]
}

struct DayDTO: Decodable {
    let date: String                // "2025-01-01"
    let events: [EventDTO]
}

struct EventDTO: Decodable {
    let danishShort: String
    let holliday   : Bool           // sic: API spelling
}

struct DayInfoDTO: Decodable {
    let date: String                 // "2025-01-01"  (we keep it as String)
    let astronomy: AstronomyDTO
    let weather:   WeatherDTO
}

struct AstronomyDTO: Decodable {
    let sunrise: String              // "08:40"
    let sunset:  String              // "15:48"
}

struct WeatherDTO: Decodable {
    let summary: [WeatherSummaryDTO] // array with "Temperatur" item
}

struct WeatherSummaryDTO: Decodable {
    let parameter:     String        // e.g. "Temperatur"
    let summaryValue:  String        // "5-9"  (min-max as a string)
    // we ignore summaryAverage & order for now
}
