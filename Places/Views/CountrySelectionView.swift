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
            VStack {
                CustomSearchBar(text: $searchText, placeholder: "Search countries") { }

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
                    .listRowBackground(StyleManager.shared.listRowBackground)
                    .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
            }
            .navigationTitle("Select a country")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarRole(.editor)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
            .onAppear { HapticsManager.shared.vibrateForSelection() }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
    }
}
