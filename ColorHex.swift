//
//  ColorHex.swift
//  Final_Project
//
//  Created by Wyne Nadi on 18/10/2568 BE.
//

import SwiftUI

extension Color {
    init(hexCode: String) {
        let sanitized = hexCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
    init(hex: String) { self.init(hexCode: hex)}
}


