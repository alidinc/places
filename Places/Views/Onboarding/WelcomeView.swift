//
//  WelcomeView.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App icon
            Image(scheme == .dark ? .icon5 : .icon)
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(radius: 10)
            
            VStack(spacing: 12) {
                Text("Welcome to Places")
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text("Your personal address book for keeping track of all your places")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: { withAnimation {
                showOnboarding = true
            } }) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(tint.color)
            .padding(50)
        }
    }
}

