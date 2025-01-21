//
//  CountrySelectionView.swift
//  Places
//
//  Created by alidinc on 17/01/2025.
//

import SwiftUI

struct CountrySelectionView: View {
    
    @Environment(CountryViewModel.self) private var countriesVM
    @Environment(\.dismiss) var dismiss
    
    @Binding var countryData: FlagData?
    
    @State private var searchText = ""
    
    var filteredCountries: [FlagData] {
        if searchText.isEmpty {
            return countriesVM.countryFlags.sorted(by: { $0.name < $1.name })
        } else {
            return countriesVM.countryFlags
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted(by: { $0.name < $1.name })
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCountries, id: \.self) { data in
                    Button {
                        countryData = data
                        dismiss()
                    } label: {
                        HStack {
                            Text("\(data.unicodeFlag) \(data.name)")
                            Spacer()
                            if countryData?.iso2 == data.iso2 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                .listRowBackground(Color.gray.opacity(0.25))
                .listRowSeparatorTint(.gray.opacity(0.45))
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search countries")
            .navigationTitle("Select a country")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .interactiveDismissDisabled()
            .toolbarRole(.editor)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(20)
    }
}
