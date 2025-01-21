//
//  MilestonesView.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import SwiftUI

struct MilestonesView: View {
    let addresses: [Address]
    @AppStorage("tint") private var tint: Tint = .blue
    
    private var longestStay: Address? {
        addresses.max(by: { $0.durationInDays < $1.durationInDays })
    }
    
    var body: some View {
        Group {
            if let longest = longestStay {
                milestoneRow(icon: "clock.fill", title: "Longest Stay") {
                    VStack(alignment: .trailing) {
                        Text(longest.mainAddressDetails)
                            .font(.subheadline)
                        Text(longest.formattedDuration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .glass()
        .padding(.horizontal)
    }
    
    private func milestoneRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(tint.color)
            }
            .font(.subheadline)
            
            Spacer()
            
            content()
        }
    }
    
    private func formatDuration(days: Int) -> String {
        let years = days / 365
        let months = (days % 365) / 30
        
        if years > 0 {
            return "\(years) year\(years > 1 ? "s" : "")\(months > 0 ? " \(months) month\(months > 1 ? "s" : "")" : "")"
        } else if months > 0 {
            return "\(months) month\(months > 1 ? "s" : "")"
        } else {
            return "\(days) day\(days != 1 ? "s" : "")"
        }
    }
}
