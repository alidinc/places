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
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
        .presentationBackground(.thinMaterial)
    }
    
    // MARK: - View Components
    private var newItemSection: some View {
        Section {
            NewItemRow(title: $newChecklistItemTitle) {
                addNewItem()
            } onAdd: {
                addNewItem(animate: false)
            }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSpacing(0)
    }
    
    private var itemsSection: some View {
        ForEach(place.checklistItems.sorted(by: { $0.title < $1.title })) { item in
            ChecklistItemRow(item: item, tint: tint) {
                toggleItem(item)
            } onDelete: {
                deleteItem(item)
            }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
    }
    
    // MARK: - Methods
    
    private func toggleItem(_ item: ChecklistItem) {
        DispatchQueue.main.async {
            withAnimation {
                item.isCompleted.toggle()
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            try? modelContext.save()
        }
    }
    
    private func deleteItem(_ item: ChecklistItem) {
        DispatchQueue.main.async {
            modelContext.delete(item)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            try? modelContext.save()
        }
    }
    
    private func addNewItem(animate: Bool = true) {
        guard !newChecklistItemTitle.isEmpty else { return }
        let title = newChecklistItemTitle
    
        newChecklistItemTitle = ""
        
        DispatchQueue.main.async {
            let item = ChecklistItem(title: title, addressId: place.id)
            withAnimation {
                place.checklistItems.append(item)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views
struct NewItemRow: View {
   
    @Binding var title: String
    let onSubmit: () -> Void
    let onAdd: () -> Void
    
    @AppStorage("tint") private var tint: Tint = .blue
    
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
