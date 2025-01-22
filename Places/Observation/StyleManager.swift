//
//  StyleManager.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

@Observable
class StyleManager {
    // MARK: - Shared Instance
    static let shared = StyleManager()
    
    // MARK: - Properties
    let listRowBackground = Color.gray.opacity(0.1)
    let listRowSeparator = Color.gray.opacity(0.45)
    let dividerColor = Color.gray.opacity(0.45)
    let footerTextColor = Color.secondary
    let headerIconSize: CGFloat = 24
    let iconSize: CGFloat = 16
    
    private init() {}
}
