//
//  ChecklistView.swift
//  Places
//
//  Created by alidinc on 17/01/2025.
//

import SwiftUI

struct ChecklistView: View {
    
    // MARK: - Properties
    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var place: Address
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var newChecklistItemTitle = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                newItemSection
                itemsSection
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Checklist for \(place.addressLine1)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .interactiveDismissDisabled()
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
        .presentationBackground(.ultraThinMaterial)
    }
    
    // MARK: - View Components
    private var newItemSection: some View {
        Section {
            NewItemRow(
                title: $newChecklistItemTitle,
                tint: tint,
                onSubmit: { addNewItem(animate: false) },
                onAdd: { addNewItem() }
            )
        }
        .listRowBackground(Color.gray.opacity(0.25))
    }
    
    private var itemsSection: some View {
        ForEach(place.checklistItems.sorted(by: { $0.title < $1.title })) { item in
            ChecklistItemRow(item: item, tint: tint) {
                toggleItem(item)
            } onDelete: {
                deleteItem(item)
            }
        }
        .listRowBackground(Color.gray.opacity(0.25))
    }
    
    // MARK: - Methods
    private func toggleItem(_ item: ChecklistItem) {
        item.isCompleted.toggle()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        try? modelContext.save()
    }
    
    private func deleteItem(_ item: ChecklistItem) {
        modelContext.delete(item)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        try? modelContext.save()
    }
    
    private func addNewItem(animate: Bool = true) {
        guard !newChecklistItemTitle.isEmpty else { return }
        
        let block = {
            let item = ChecklistItem(title: newChecklistItemTitle, addressId: place.id)
            place.checklistItems.append(item)
            newChecklistItemTitle = ""
            try? modelContext.save()
        }
        
        animate ? withAnimation { block() } : block()
    }
}

// MARK: - Supporting Views
struct NewItemRow: View {
    @Binding var title: String
    
    let tint: Tint
    let onSubmit: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
            
            TextField("Add new item", text: $title)
                .onSubmit(onSubmit)
            
            if !title.isEmpty {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(tint.color)
                }
            }
        }
    }
}

struct ChecklistItemRow: View {
    
    let item: ChecklistItem
    let tint: Tint
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? tint.color : .secondary)
                
                Text(item.title)
                    .strikethrough(item.isCompleted)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}
