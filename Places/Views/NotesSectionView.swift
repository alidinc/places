//
//  NotesSectionView.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import SwiftUI
import SwiftData

struct NotesSectionView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var place: Address
    
    @State private var showNotesView = false
    
    var body: some View {
        Section("Notes") {
            Button {
                showNotesView = true
            } label: {
                HStack {
                    Text("Go to your notes")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(place.notes.count, format: .number)
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(tint.color)
            .sheet(isPresented: $showNotesView) {
                NotesView(place: place)
            }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
}
