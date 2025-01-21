//
//  HUDState.swift
//  Places
//
//  Created by alidinc on 21/01/2025.
//

import SwiftUI

@Observable
final class HUDState {
    var isPresented: Bool = false
    private(set) var title: String = ""
    private(set) var systemImage: String = ""
    
    func show(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
        withAnimation {
            isPresented = true
        }
    }
}

