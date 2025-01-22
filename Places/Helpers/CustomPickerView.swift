//
//  CustomPickerView.swift
//  Places
//
//  Created by alidinc on 18/01/2025.
//

import SwiftUI

struct CustomPickerView<T: Hashable>: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Binding var selection: T
    let items: [T]
    let itemTitle: (T) -> String
    
    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                        selection = item
                    }
                } label: {
                    Text(itemTitle(item))
                        .hSpacing(.center)
                        .vSpacing(.center)
                        .font(.subheadline.weight(.semibold))
                        .background(selection == item ? tint.color.opacity(0.5) : Color.clear, in: .rect(cornerRadius: 8))
                        .foregroundStyle(selection == item ? .white : .secondary)
                        .frame(maxHeight: 30)
                }
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .background {
            StyleManager.shared.listRowBackground
                .clipShape(.rect(cornerRadius: 8))
        }
        .hSpacing(.center)
    }
}
