//
//  SearchView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

struct SearchView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var vm: PlacesViewModel
    @Binding var showAddManual: Bool

    @FocusState private var focused: Bool

    var body: some View {
        VStack {
            SearchResultsView
            SearchTextField
        }
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        .padding()
    }

    private var SearchTextField: some View {
        HStack(spacing: 10) {
            TextField("Search for address", text: $vm.searchQuery)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .focused($focused)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .autocorrectionDisabled()
                .showClearButton($vm.searchQuery, action: { vm.searchQuery = "" })

            Button {
                showAddManual = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint.color.gradient)
            }
        }
        .padding(.leading, 8)
        .padding(.trailing)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var SearchResultsView: some View {
        if vm.isSearching {
            ProgressView("Searching for addresses...")
                .padding()
                .transition(.move(edge: .bottom))
        } else if !vm.searchResults.isEmpty {
            List(vm.searchResults) { result in
                Button {
                    vm.selectedSearchResult = result
                    vm.isPresentingPlaceTypeView = true
                    vm.searchQuery = ""
                    vm.searchResults = []
                    focused = false
                } label: {
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.headline)

                        Text(result.detailedAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .hSpacing(.leading)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                }
                .listRowInsets(.init())
                .listRowBackground(Color(.clear))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding(12)
            .scrollContentBackground(.hidden)
            .transition(.move(edge: .bottom))
            .frame(height: vm.searchResults.isEmpty ? 0 : (vm.searchResults.count > 1 ? 250 : 150))
            .animation(.easeInOut, value: vm.searchResults.count)
        }
    }
}
