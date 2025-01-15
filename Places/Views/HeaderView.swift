//
//  HeaderView.swift
//  Places
//
//  Created by alidinc on 14/01/2025.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    
    @Environment(CountryViewModel.self) var countriesVM
    @Query private var savedAddresses: [Address]
    @State private var showingCopyAlert = false
    
    var currentAddress: Address? { savedAddresses.first(where: { $0.isCurrent }) }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let currentAddress {
                Text("You currently live in")
                
                countryNameWithFlag(for: currentAddress.country)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(currentAddress.mainAddressDetails)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(currentAddress.localityDetails)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    ActionsButton(address: currentAddress, showingCopyAlert: $showingCopyAlert)
                }
            }
        }
        .font(.headline)
        .contentTransition(.opacity)
        .padding(.horizontal, 20)
        .frame(height: UIScreen.main.bounds.height / 4.5)
        .animation(.easeInOut, value: currentAddress)
        .alert("Address copied to clipboard", isPresented: $showingCopyAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func countryNameWithFlag(for country: String) -> some View {
        HStack {
            Text(country.isEmpty ? "Unknown Country" : country)
            
            if let flag = countriesVM.countryFlags.first(where: { $0.name?.lowercased() == country.lowercased() }) {
                Text(flag.unicodeFlag ?? "")
            }
        }
        .font(.system(size: 40).weight(.semibold))
    }
}
