//
//  WeatherBlockView.swift
//  Calendar
//
//  Created by Jakob Jacobsen on 5/1/25.
//

import SwiftUI
struct WeatherBlockView: View {
    let info: DayInfoItem
    var body: some View {
        HStack(spacing: 10) {
            Label {
                Text("\(Int(info.tempMin)) – \(Int(info.tempMax)) °C")
            } icon: {
                Image(systemName: "thermometer")
                    .foregroundColor(.red)
            }
            
            if let rise = info.sunrise {
                Label {
                    Text("\(rise)")
                } icon: {
                    Image(systemName: "sunrise")
                        .foregroundColor(.orange)
                }
            }
            
            if let set = info.sunset {
                Label {
                    Text("\(set)")
                } icon: {
                    Image(systemName: "sunset")
                        .foregroundColor(.orange)
                }
            }
        }
        .font(.caption)
    }
}


             
