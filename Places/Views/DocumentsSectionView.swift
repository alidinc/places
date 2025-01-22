//
//  DocumentsSectionView.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import SwiftUI
import SwiftData
import QuickLook
import UniformTypeIdentifiers

struct DocumentsSectionView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Binding var documents: [DocumentItem]
    @Binding var previewURL: URL?
    @Environment(\.modelContext) private var modelContext
    
    @State private var showDocumentPicker = false
    @State private var selectedDocumentType: DocumentType = .rentalAgreement
    @State private var showDeleteAlert = false
    @State private var documentToDelete: DocumentItem?
    
    var body: some View {
        Section(header: Text("Documents")) {
            addDocumentButton
            documentsListView
        }
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
        .listRowBackground(StyleManager.shared.listRowBackground)
        .alert("Would you like to delete this document?", isPresented: $showDeleteAlert, actions: {
            HStack {
                Button("Cancel", role: .cancel) { }
                Button("OK", role: .cancel) {
                    deleteDocument(documentToDelete)
                }
            }
        })
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            handleDocumentSelection(result)
        }
    }
    
    private var documentsListView: some View {
        ForEach(documents) { document in
            Button {
                showDocumentPreview(document)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(document.name)
                            .font(.subheadline)
                        Text(document.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        documentToDelete = document
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .contentShape(.rect)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 6)
    }
    
    private var addDocumentButton: some View {
        HStack {
            Menu {
                Picker(selection: $selectedDocumentType) {
                    ForEach(DocumentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                } label: {
                    Text(selectedDocumentType.rawValue)
                }
                .pickerStyle(.inline)
            } label: {
                HStack {
                    Text(selectedDocumentType.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .hSpacing(.leading)
            
            Button {
                showDocumentPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .capsuleButtonStyle()
            }
            .contentShape(.rect)
            .buttonStyle(.plain)
        }
        .contentShape(.rect)
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        do {
            guard let selectedURL = try result.get().first else { return }
            
            if selectedURL.startAccessingSecurityScopedResource() {
                defer { selectedURL.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: selectedURL)
                let document = DocumentItem(
                    name: selectedURL.lastPathComponent,
                    data: data,
                    type: selectedDocumentType
                )
                
                documents.append(document)
                try? modelContext.save()
            }
        } catch {
            print("Error selecting document: \(error.localizedDescription)")
        }
    }
    
    private func showDocumentPreview(_ document: DocumentItem) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.name)
        try? document.data.write(to: tempURL)
        previewURL = tempURL
    }
    
    private func deleteDocument(_ document: DocumentItem?) {
        if let document {
            documents.removeAll { $0.id == document.id }
            try? modelContext.save()
        }
    }
}
