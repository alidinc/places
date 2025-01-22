//
//  ContactsView.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import SwiftUI

struct ContactsView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    @Environment(ContactsManager.self) private var contactsManager
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focused: Bool
    @State private var searchText = ""
    
    var contactSelected: (_ contact: Contact) -> Void
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contactsManager.contacts.sorted(by: { $0.name < $1.name })
        } else {
            return contactsManager.contacts.filter { contact in
                contact.name.lowercased().contains(searchText.lowercased()) ||
                contact.phone.contains(searchText)
            }.sorted(by: { $0.name < $1.name })
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if contactsManager.isFetching {
                    VStack {
                        ProgressView("Loading contacts...")
                            .padding()
                        Text("Fetching contacts, please wait.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(filteredContacts, id: \.id) { contact in
                            Button {
                                contactSelected(contact)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    if let image = contact.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(contact.name)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(contact.phone)
                                            .foregroundStyle(tint.color)
                                            .font(.caption.weight(.medium))
                                    }
                                }
                                .hSpacing(.leading)
                            }
                        }
                        .listRowBackground(StyleManager.shared.listRowBackground)
                        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.top, -20)
                    .searchable(text: $searchText,
                               placement: .navigationBarDrawer(displayMode: .always),
                               prompt: "Search contacts")
                }
            }
            .navigationTitle("Choose a contact name")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: contactsManager.fetchContacts)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.thinMaterial)
        .presentationCornerRadius(20)
    }
}
