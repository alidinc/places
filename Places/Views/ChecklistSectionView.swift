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
                // Progress Chart
                chartView
                // Status Text
                statusView
                Spacer()
                // View Button
                viewButton
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Color.gray.opacity(0.25))
        .listRowSeparatorTint(.gray.opacity(0.45))
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
            HStack(spacing: 4) {
                Text("\(place.checklistItems.filter({ $0.isCompleted }).count, format: .number) / \(place.checklistItems.count, format: .number)")
                    .contentTransition(.numericText())
                    .font(.headline.weight(.medium))
                
                Text("completed")
                    .foregroundStyle(.secondary)
            }
            
            let progress = Float(place.checklistItems.filter({ $0.isCompleted }).count) / Float(place.checklistItems.count) * 100
            Text(String(format: "%.0f%% completed", progress))
                .font(.footnote)
                .foregroundStyle(.secondary)
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

