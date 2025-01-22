//
//  Contact.swift
//  Places
//
//  Created by alidinc on 21/01/2025.
//

import UIKit

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phone: String
    let image: UIImage?
    
    init(name: String, phone: String, image: UIImage? = nil) {
        self.name = name
        self.phone = phone
        self.image = image
    }
}

