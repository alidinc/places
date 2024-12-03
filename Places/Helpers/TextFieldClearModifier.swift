//
//  TextFieldClearModifier.swift
//  Tasks
//
//  Created by Ali Dinç on 14/06/2024.
//

import SwiftUI

struct TextFieldClearButton: ViewModifier {
	@Binding var fieldText: String
	let action: () -> Void

	func body(content: Content) -> some View {
		content
			.overlay {
				if !fieldText.isEmpty {
					HStack {
						Spacer()
						Button {
                            withAnimation {
                                action()
                            }
						} label: {
							Image(systemName: "delete.left.fill")
						}
						.foregroundColor(.secondary)
						.padding(.trailing, 10)
					}
				}
			}
	}
}

extension View {
	func showClearButton(_ text: Binding<String>, action: @escaping () -> Void) -> some View {
		self.modifier(TextFieldClearButton(fieldText: text, action: action))
	}
}
