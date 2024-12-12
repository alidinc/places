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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: .capsule)
    }
}

extension View {
    func capsule() -> some View {
        modifier(CapsuleModifier())
    }
}
