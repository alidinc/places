//
//  CapsuleModifier.swift
//  Vitals
//
//  Created by alidinc on 25/11/2024.
//

import SwiftUI

struct CapsuleModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .font(.system(size: 14).weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: .capsule)
    }
}

extension View {
    func capsule() -> some View {
        modifier(CapsuleModifier())
    }
}
