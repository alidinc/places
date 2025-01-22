//
//  OwnerDetailsView.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct OwnerDetailsView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Binding var ownerName: String
    @Binding var relationship: String
    @Binding var showContactsList: Bool
    @Binding var image: UIImage?
    
    var body: some View {
        Section("Resident") {
            VStack(alignment: .leading) {
                HStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.gray)
                    }
                    
                    TextField("Name", text: $ownerName)
                    
                    Spacer()
                }
                
                Button {
                    showContactsList = true
                } label: {
                    HStack {
                        Text("Choose from your contacts list")
                            .foregroundStyle(tint.color)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .contentShape(.rect)
                
                Divider().background(.gray.opacity(0.45))
                
                HStack {
                    Text("Relationship")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    TextField("Relationship", text: $relationship)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
}

