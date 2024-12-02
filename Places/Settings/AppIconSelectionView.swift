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
        List {
            ForEach(AppIcon.allCases) { icon in
                HStack {
                    Image(icon.assetName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(icon.title)
                    Spacer()
                    if icon == selectedAppIcon {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAppIcon = icon
                    updateIcon(to: icon)
                }
            }
        }
        .navigationTitle("App Icon")
    }

    func updateIcon(to icon: AppIcon) {
        // Update the app icon
        UIApplication.shared.setAlternateIconName(icon.iconName) { error in
            if let error = error {
                print("Error setting alternate icon: \(error.localizedDescription)")
            }
        }
    }
}
