//
//  SettingsRowView.swift
//  Steps
//
//  Created by Ali Dinç on 14/08/2024.
//

import SwiftUI

struct SettingsRowView<Content: View>: View {

    @AppStorage("tint") private var tint: Tint = .blue

    let icon: String
    let title: LocalizedStringResource
    let trailingContent: Content

    init(icon: String, title: LocalizedStringResource, @ViewBuilder trailingContent: () -> Content = { EmptyView() }) {
        self.icon = icon
        self.title = title
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint.color.gradient)
                .frame(width: 24, height: 24, alignment: .center)

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()
            trailingContent
        }
        .padding(.vertical, 4)
    }
}
