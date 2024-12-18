//
//  GradientModifier.swift
//  Vitals
//
//  Created by Ali Dinç on 28/10/2024.
//

import SwiftUI

struct GradientModifier: ViewModifier {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.colorScheme) private var scheme
    var withBlack: Bool = true

    private var gradientColors: [Color] {
        let label = scheme == .dark ? Color.black : Color.white.opacity(0.25)
        return [
            label,
            label,
            tint.color.opacity(0.05),
            tint.color.opacity(0.1),
            tint.color.opacity(0.1),
            tint.color.opacity(0.15),
            tint.color.opacity(0.25)
        ]
    }

    private var withoutBlackGradientColors: [Color] {
        return [
            tint.color.opacity(0.15),
            tint.color.opacity(0.25)
        ]
    }

    func body(content: Content) -> some View {
        content
            .background {
                if scheme == .dark {
                    LinearGradient(colors: withBlack ? gradientColors : withoutBlackGradientColors,
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .ignoresSafeArea()
                } else {
                    Color.clear
                }
            }
    }
}

extension View {
    func gradientBackground(withBlack: Bool = true) -> some View {
        self.modifier(GradientModifier(withBlack: withBlack))
    }
}
