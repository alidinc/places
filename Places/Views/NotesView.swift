//
//  NotesView.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import SwiftUI
import SwiftData

struct NotesView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var place: Address

    @State private var newNoteText = ""
    @State private var editingNote: Note?
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: Note?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Add a new note", text: $newNoteText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5)
                        .submitLabel(.done)
                        .onSubmit(addNewNote)

                    if !newNoteText.isEmpty {
                        Button(action: addNewNote) {
                            Label("Add Note", systemImage: "plus.circle.fill")
                                .foregroundStyle(tint.color)
                        }
                    }
                }
                .listRowBackground(StyleManager.shared.listRowBackground)

                if place.notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description:  Text("Add notes to this address using the text field above.")
                    )
                    .scaleEffect(0.85)
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(place.notes.sorted(by: { $0.updatedAt > $1.updatedAt })) { note in
                            NoteRowView(note: note) {
                                noteToDelete = note
                                showingDeleteAlert = true
                            }
                        }
                    }
                    .listRowBackground(StyleManager.shared.listRowBackground)
                }

            }
            .padding(.top, -20)
            .scrollContentBackground(.hidden)
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton()
                }
            }
            .alert("Delete Note", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let note = noteToDelete {
                        deleteNote(note)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this note?")
            }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
    }

    @MainActor
    private func addNewNote() {
        let note = Note(text: newNoteText)
        place.notes.append(note)
        newNoteText = ""
        try? modelContext.save()
    }

    @MainActor
    private func updateNote(_ note: Note, with text: String) {
        note.text = text
        note.updatedAt = Date()
        try? modelContext.save()
    }

    @MainActor
    private func deleteNote(_ note: Note) {
        withAnimation {
            place.notes.removeAll(where: { $0.id == note.id })
        }
        modelContext.delete(note)
        try? modelContext.save()
    }
}

struct NoteRowView: View {

    @Bindable var note: Note
    var onDelete: () -> Void

    @AppStorage("tint") private var tint: Tint = .blue

    var body: some View {
        VStack {
            TextEditor(text: $note.text)
                .frame(maxHeight: 100)

            HStack {
                Text(note.updatedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .contentShape(.rect)
            }
            .font(.caption)
        }
        .padding(12)
        .listRowInsets(.init())
    }
}
