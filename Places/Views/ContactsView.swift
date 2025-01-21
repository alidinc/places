//
//  ContactsView.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import SwiftUI

struct ContactsView: View {
    
    @Environment(ContactsManager.self) private var contactsManager
    @Environment(\.dismiss) private var dismiss
    
    var contactSelected: (_ contact: Contact) -> Void
    
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
                    Form {
                        ForEach(contactsManager.contacts.sorted(by: { $0.name < $1.name }), id: \.id) { contact in
                            Button {
                                contactSelected(contact)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(contact.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .listRowBackground(Color.gray.opacity(0.25))
                        .listRowSeparatorTint(.gray.opacity(0.45))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Choose a contact name")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: contactsManager.fetchContacts)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(20)
    }
}
