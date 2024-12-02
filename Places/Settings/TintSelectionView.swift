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
            .pickerStyle(.inline)
            .onChange(of: selectedTint) { _,_ in
                dismiss()
            }
        }
        .navigationTitle("App Tint Color")
    }
}
