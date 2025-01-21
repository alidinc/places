//
//  ContactsManager.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import Foundation
import Contacts
import SwiftUI

@Observable
class ContactsManager {
    
    var contacts: [Contact] = []
    var isFetching: Bool = false
    
    func fetchContacts() {
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPostalAddressesKey] as [CNKeyDescriptor]
            
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else { return }
                
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                var fetchedContacts: [Contact] = []
                
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        let name = "\(contact.givenName) \(contact.familyName)"
                        
                        fetchedContacts.append(Contact(name: name, phone: ""))
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                        self.isFetching = false
                    }
                } catch {
                    print("Failed to fetch contacts: \(error)")
                }
            }
        }
    }
}

struct Contact {
    let id: String
    let name: String
    let phone: String
    
    init(id: String = UUID().uuidString, name: String, phone: String) {
        self.id = id
        self.name = name
        self.phone = phone
    }
}
