//
//  CapsuleButtonModifier.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct CapsuleButtonModifier: ViewModifier {
    
    @AppStorage("tint") private var tint: Tint = .blue
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.medium))
            .foregroundStyle(tint.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: .capsule)
            .padding(4)
    }
}

extension View {
    func capsuleButtonStyle() -> some View {
        modifier(CapsuleButtonModifier())
    }
}
