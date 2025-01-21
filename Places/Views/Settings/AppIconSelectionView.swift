//
//  AppIconSelectionView.swift
//  Steps
//
//  Created by alidinc on 01/12/2024.
//

import SwiftUI

struct AppIconSelectionView: View {

    @Binding var selectedAppIcon: AppIcon
    @Environment(\.colorScheme) var scheme

    var body: some View {
        NavigationStack {
            List {
                Section("App Icon") {
                    ForEach(AppIcon.allCases, id: \.id) { icon in
                        Button {
                            updateIcon(to: icon)
                        } label: {
                            HStack {
                                Image(icon.assetName)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(.rect(cornerRadius: 8))
                                Text(icon.title)
                                Spacer()
                                if icon == selectedAppIcon {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.vertical, 3)
                        }
                        .tag(icon.id)
                    }
                    .listRowBackground(Color.gray.opacity(0.25))
                    .listRowSeparatorTint(.gray.opacity(0.45))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(20)
    }

    func updateIcon(to icon: AppIcon) {
        // Update the app icon
        selectedAppIcon = icon
        
        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                /// No need to update since we're already using this icon.
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
                print("Updating icon to \(String(describing: icon.iconName)) succeeded.")
            } catch {
                print("Updating icon to \(String(describing: icon.iconName)) failed.")
                try await UIApplication.shared.setAlternateIconName(nil)
            }
        }
    }
}
