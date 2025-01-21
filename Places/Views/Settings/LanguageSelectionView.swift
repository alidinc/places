//
//  LocalizationView.swift
//  Tasks
//
//  Created by Ali Dinç on 20/07/2024.
//

import SwiftUI

struct LanguageSelectionView: View {

    @Binding var selectedLanguage: Language
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Language") {
                    ForEach(Language.allCases, id: \.id) { language in
                        Button {
                            selectedLanguage = language
                        } label: {
                            HStack {
                                Text("\(language.flag) \(language.title)")
                                Spacer()
                                if selectedLanguage.id == language.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .tag(language.id)
                    }
                    .listRowBackground(Color.gray.opacity(0.25))
                    .listRowSeparatorTint(.gray.opacity(0.45))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedLanguage) { _,_ in dismiss() }
            .scrollContentBackground(.hidden)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(20)
    }
}
