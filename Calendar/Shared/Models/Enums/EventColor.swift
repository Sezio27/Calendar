//
//  EventColor.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 3/26/25.
//

import SwiftUI

enum EventColor: String, CaseIterable {
    case red
    case blue
    case green
    case orange
    case purple
    
    // Convert this enum case to a SwiftUI Color
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        }
    }
    
    // Display-friendly name if needed
    var displayName: String {
        rawValue.capitalized
    }
}
