//
//  TenancyDatePicker.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import Foundation
import SwiftUI

struct PlaceTypeView: View {

    let searchResult: SearchResult
    let onSave: (PlaceType, Date?, Date?) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlaceType: PlaceType = .residentialTenancy
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(searchResult.detailedAddress ?? "")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                Picker("Select Place Type", selection: $selectedPlaceType) {
                    ForEach(PlaceType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedPlaceType == .residentialTenancy {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Spacer()

                Button(action: {
                    if selectedPlaceType == .residentialTenancy && startDate > endDate {
                        // Optionally display an error message
                        return
                    }
                    onSave(selectedPlaceType, selectedPlaceType == .residentialTenancy ? startDate : nil, selectedPlaceType == .residentialTenancy ? endDate : nil)
                    dismiss()
                }) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedPlaceType == .residentialTenancy && startDate > endDate)
            }
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}
