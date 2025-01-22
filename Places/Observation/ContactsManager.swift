//
//  ContactsManager.swift
//  Places
//
//  Created by alidinc on 16/01/2025.
//

import Foundation
import Contacts
import SwiftUI
import UIKit

@Observable
class ContactsManager {
    
    var contacts: [Contact] = []
    var isFetching: Bool = false
    
    func fetchContacts() {
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactThumbnailImageDataKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactPostalAddressesKey] as [CNKeyDescriptor]
            
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else { return }
                
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                var fetchedContacts: [Contact] = []
                
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        let name = "\(contact.givenName) \(contact.familyName)"
                        let phone = contact.phoneNumbers.first?.value
                        var contactImage: UIImage? = nil
                        
                        if let thumbnailData = contact.thumbnailImageData {
                            contactImage = UIImage(data: thumbnailData)
                        }
                        
                        fetchedContacts.append(
                            Contact(
                                name: name,
                                phone: phone?.stringValue ?? "",
                                image: contactImage
                            )
                        )
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
