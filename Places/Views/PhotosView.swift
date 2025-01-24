//
//  PhotosView.swift
//  Places
//

import SwiftUI
import SwiftData
import PhotosUI

struct PhotosView: View {
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var place: Address

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var selectedGridPhoto: Photo?
    @State private var isSelectionMode = false
    @State private var selectedPhotos: Set<UUID> = []
    @State private var showDeleteAlert = false

    // Calculate grid size
    var gridItemSize: CGFloat {
        let spacing: CGFloat = 1
        let numberOfColumns: CGFloat = 3
        // Subtract navigation bar and padding
        let availableWidth = UIScreen.main.bounds.width - (spacing * (numberOfColumns - 1))
        return availableWidth / numberOfColumns
    }

    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if place.photos.isEmpty {
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.on.rectangle",
                        description:  Text("Add photos to this address by tapping the plus button.")
                    )
                    .scaleEffect(0.85)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(place.photos) { photo in
                                // Use thumbnail data for grid
                                if let uiImage = UIImage(data: photo.thumbnailData) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: gridItemSize, height: gridItemSize)
                                            .clipped()
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if isSelectionMode {
                                                    toggleSelection(photo)
                                                } else {
                                                    selectedGridPhoto = photo
                                                }
                                            }

                                        if isSelectionMode {
                                            Image(systemName: selectedPhotos.contains(photo.id) ? "checkmark.circle.fill" : "circle")
                                                .font(.title3)
                                                .foregroundStyle(selectedPhotos.contains(photo.id) ? tint.color : .white)
                                                .padding(8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedPhotos.removeAll()
                        }
                    } else {
                        Button {
                            showPhotoPicker = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(tint.color)
                                .font(.title3)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete \(selectedPhotos.count)")
                                .foregroundStyle(.red)
                        }
                        .disabled(selectedPhotos.isEmpty)
                    } else {
                        HStack(spacing: 16) {
                            if !place.photos.isEmpty {
                                Button("Select") {
                                    isSelectionMode = true
                                }
                            }
                            DismissButton()
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let newValue,
                       let imageData = try? await newValue.loadTransferable(type: Data.self) {
                        let photo = Photo(imageData: imageData)
                        place.photos.append(photo)
                        try? modelContext.save()
                    }
                }
            }
            .sheet(item: $selectedGridPhoto) { photo in
                SinglePhotoView(photo: photo) { photo in
                    deletePhoto(photo)
                }
            }
            .alert("Delete Photos", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteSelectedPhotos()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedPhotos.count) photos?")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
    }

    private func toggleSelection(_ photo: Photo) {
        if selectedPhotos.contains(photo.id) {
            selectedPhotos.remove(photo.id)
        } else {
            selectedPhotos.insert(photo.id)
        }
    }

    private func deleteSelectedPhotos() {
        for photoID in selectedPhotos {
            if let photo = place.photos.first(where: { $0.id == photoID }) {
                deletePhoto(photo)
            }
        }
        isSelectionMode = false
        selectedPhotos.removeAll()
    }

    private func deletePhoto(_ photo: Photo) {
        if let index = place.photos.firstIndex(where: { $0.id == photo.id }) {
            place.photos.remove(at: index)
            modelContext.delete(photo)
            try? modelContext.save()
        }
    }
}

struct SinglePhotoView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("tint") private var tint: Tint = .blue

    let photo: Photo
    let onDelete: (Photo) -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            // Use full-size image data for detail view
            if let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }

                        ToolbarItem(placement: .topBarLeading) {
                            DismissButton()
                        }
                    }
            }
        }
        .alert("Delete Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete(photo)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this photo?")
        }
    }
}
