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
                    selection = item
                } label: {
                    Text(itemTitle(item))
                        .hSpacing(.center)
                        .vSpacing(.center)
                        .font(.headline)
                        .fontWeight(selection == item ? .bold : .regular)
                        .background(selection == item ? tint.color.opacity(0.5) : Color.clear, in: .rect(cornerRadius: 8))
                        .foregroundStyle(selection == item ? .white : .secondary)
                        .frame(maxHeight: 30)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
