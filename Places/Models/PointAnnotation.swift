//
//  PointAnnotation.swift
//  Places
//
//  Created by alidinc on 20/01/2025.
//

import SwiftData
import CoreLocation

@Model
class PointAnnotation {
    
    var id: String
    var latitude: Double
    var longitude: Double
    var name: String
    var addressOwner: AddressOwner
    
    init(id: String, latitude: Double, longitude: Double, name: String, addressOwner: AddressOwner) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.addressOwner = addressOwner
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
