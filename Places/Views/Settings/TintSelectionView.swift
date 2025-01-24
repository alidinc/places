//
//  TintSelectionView.swift
//  Steps
//
//  Created by alidinc on 01/12/2024.
//

import SwiftUI

struct TintSelectionView: View {
    @Binding var selectedTint: Tint
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("App Tint Color", selection: $selectedTint) {
                    ForEach(Tint.allCases) { tintOption in
                        HStack {
                            Circle()
                                .fill(tintOption.color)
                                .frame(width: 18, height: 18)

                            Text(tintOption.title)
                        }
                        .tag(tintOption)
                    }
                }
                .listRowBackground(StyleManager.shared.listRowBackground)
                .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
                .pickerStyle(.inline)
                .onChange(of: selectedTint) { _,_ in
                    dismiss()
                }
            }
            .navigationTitle("Choose a Tint Colour")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(20)
    }
}
