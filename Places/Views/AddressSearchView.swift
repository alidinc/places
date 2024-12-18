//
//  AddressSearchView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftUI

struct AddressSearchView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @Bindable var vm: AddressLookUpViewModel
    @Binding var showAddManual: Bool
    @Binding var isFocused: Bool

    @Environment(\.colorScheme) private var scheme
    @FocusState private var focused: Bool

    var body: some View {
        VStack {
            SearchResultsView
            SearchTextField
        }
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
        .animation(.easeInOut, value: vm.searchResults.count)
        .animation(.easeInOut, value: vm.isSearching)
        .padding(.horizontal)
        .padding(.bottom)
        .onChange(of: isFocused) { _, newValue in
            self.focused = newValue
        }
    }

    @ViewBuilder
    private var SearchResultsView: some View {
        if vm.isSearching {
            ProgressView("Searching...")
                .padding(.top, 20)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .blurReplace))
        } else if !vm.searchResults.isEmpty {
            List(vm.searchResults) { result in
                Button {
                    vm.presentAddPlaceView = true
                    vm.selectedSearchResult = result
                    vm.searchResults = []
                    vm.searchQuery = ""
                    focused = false
                } label: {
                    Text(result.searchAddress)
                        .font(.headline)
                        .padding()
                        .hSpacing(.leading)
                        .background(.black.opacity(scheme == .light ? 0.25 : 0.75), in: .rect(cornerRadius: 12))
                        .padding(.trailing, 12)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 5, trailing: 0))
                .listRowBackground(Color(.clear))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding(.vertical, 12)
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .scrollContentBackground(.hidden)
            .transition(.asymmetric(insertion: .push(from: .bottom).combined(with: .opacity),
                                    removal: .push(from: .top).combined(with: .opacity)))
            .frame(height: calculateDynamicHeight())
        }
    }

    private func calculateDynamicHeight() -> CGFloat {
        let baseRowHeight: CGFloat = 140 // Adjust to match the actual height of each row
        let maxVisibleRows: Int = 3    // Limit the number of rows to show at once
        let maxHeight = CGFloat(maxVisibleRows) * baseRowHeight
        return min(CGFloat(vm.searchResults.count) * baseRowHeight, maxHeight)
    }

    private var SearchTextField: some View {
        HStack(spacing: 10) {
            TextField("Search here...", text: $vm.searchQuery)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .focused($focused)
                .background(Color.black.opacity(0.15), in: .rect(cornerRadius: 18))
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
}
