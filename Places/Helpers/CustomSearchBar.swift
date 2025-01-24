//
//  CustomSearchBar.swift
//  Places
//

import SwiftUI

struct CustomSearchBar: View {
    
    @Binding var text: String
    @Binding var focused: Bool
    let placeholder: String
    let onTextChanged: () -> Void

    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        focused: Binding<Bool> = .constant(false),
        placeholder: String,
        onTextChanged: @escaping () -> Void
    ) {
        self._text = text
        self._focused = focused
        self.placeholder = placeholder
        self.onTextChanged = onTextChanged
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tertiary)

            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
                .focused($isFocused)
                .showClearButton($text, action: {
                    withAnimation {
                        text = ""
                    }
                })
                .onChange(of: text) { onTextChanged() }
                .onAppear {
                    isFocused = focused
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thickMaterial.opacity(0.65), in: .rect(cornerRadius: 12))
        .padding(.horizontal)
    }
}
