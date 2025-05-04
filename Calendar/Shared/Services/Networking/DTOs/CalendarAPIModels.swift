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
    let date: String                
    let events: [EventDTO]
}

struct EventDTO: Decodable {
    let danishShort: String
    let holliday   : Bool
}

struct DayInfoDTO: Decodable {
    let date: String
    let astronomy: AstronomyDTO
    let weather:   WeatherDTO
}

struct AstronomyDTO: Decodable {
    let sunrise: String
    let sunset:  String
}

struct WeatherDTO: Decodable {
    let summary: [WeatherSummaryDTO]
}

struct WeatherSummaryDTO: Decodable {
    let parameter:     String
    let summaryValue:  String
    
}
