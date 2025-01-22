//
//  StyleManager.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct AdaptiveColor: View {
    
    let light: Color
    let dark: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        colorScheme == .dark ? dark : light
    }
}

@Observable
class StyleManager {
    // MARK: - Shared Instance
    static let shared = StyleManager()
    
    // MARK: - Properties
    var listRowBackground: some View {
        AdaptiveColor(
            light: .gray.opacity(0.15),
            dark: .black.opacity(0.25)
        )
    }
    
    var listRowSeparator: Color = .gray.opacity(0.45)
    var dividerColor: Color = .gray.opacity(0.45)
    
    let footerTextColor = Color.secondary
    let headerIconSize: CGFloat = 24
    let iconSize: CGFloat = 16
    
    private init() {}
}
