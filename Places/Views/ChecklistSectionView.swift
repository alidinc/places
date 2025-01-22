//
//  ChecklistSectionView.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct ChecklistSectionView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    let place: Address
    @Binding var showChecklist: Bool
    
    var body: some View {
        Section(header: Text("Checklist")) {
            HStack(spacing: 16) {
                chartView
                statusView
                Spacer()
                viewButton
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
    
    private var chartView: some View {
        ZStack {
            let completedCount = place.checklistItems.filter({ $0.isCompleted }).count
            let totalCount = place.checklistItems.count
            let isAllCompleted = completedCount == totalCount
            
            // Background circle
            Circle()
                .fill(isAllCompleted ? Color.green.opacity(0.2) : Color.clear)
                .frame(width: 32, height: 32)
            
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                .frame(width: 32, height: 32)
            
            Circle()
                .trim(from: 0, to: CGFloat(completedCount) / CGFloat(totalCount))
                .stroke(isAllCompleted ? Color.green : tint.color, lineWidth: 4)
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))
            
            // Checkmark
            if isAllCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.green)
            }
        }
    }
    
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(place.checklistItems.filter({ $0.isCompleted }).count, format: .number) / \(place.checklistItems.count, format: .number)")
                .contentTransition(.numericText())
                .font(.headline.weight(.medium))
            
            let completedCount = place.checklistItems.filter({ $0.isCompleted }).count
            let totalCount = place.checklistItems.count
            let isAllCompleted = completedCount == totalCount && totalCount != 0
            
            Text(isAllCompleted ? "All completed" : (totalCount == 0 ? "No items found" : String(format: "%.0f%% completed", Float(completedCount) / Float(totalCount) * 100)))
                .font(.footnote)
                .foregroundStyle(isAllCompleted ? .green : .secondary)
        }
    }
    
    private var viewButton: some View {
        Button {
            showChecklist = true
        } label: {
            Text("View Checklist")
        }
        .capsuleButtonStyle()
    }
}

