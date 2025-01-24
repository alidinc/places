//
//  AttachmentsSectionView.swift
//  Places
//

import SwiftUI
import SwiftData

struct AttachmentsSectionView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var place: Address
    
    @State private var showNotesView = false
    @State private var showPhotosView = false
    
    var body: some View {
        Section("Attachments") {
            Button {
                showPhotosView = true
            } label: {
                HStack {
                    Label("Photos", systemImage: "photo.stack")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Text(place.photos.count, format: .number)
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(.secondary)
            .sheet(isPresented: $showPhotosView) { PhotosView(place: place) }

            Button {
                showNotesView = true
            } label: {
                HStack {
                    Label("Notes", systemImage: "note.text")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Text(place.notes.count, format: .number)
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(.secondary)
            .sheet(isPresented: $showNotesView) { NotesView(place: place) }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
}
