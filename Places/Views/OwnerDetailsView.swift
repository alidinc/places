//
//  OwnerDetailsView.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI
import PhotosUI

struct OwnerDetailsView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Binding var ownerName: String
    @Binding var relationship: String
    @Binding var showContactsList: Bool
    @Binding var showImagePicker: Bool
    @Binding var image: UIImage?
    
    var body: some View {
        Section("Resident") {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        showImagePicker = true
                    } label: {
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
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    
                    
                    TextField("Name", text: $ownerName)
                    
                    Spacer()
                    
                    Button {
                        showContactsList = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Contacts")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(tint.color)
                    }
                    .buttonStyle(.plain)
                    .contentShape(.rect)
                }
                
                Divider().background(StyleManager.shared.dividerColor)
                
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
