//
//  LocationsManager.swift
//  Places
//
//  Created by alidinc on 18/01/2025.
//

import MapKit
import SwiftUI
import CoreLocation

@Observable
class LocationsManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    var isAuthorized: Bool = false
    
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var hasRequestedAuthorization: Bool {
        get { UserDefaults.standard.bool(forKey: "hasRequestedLocationAuthorization") }
        set { UserDefaults.standard.setValue(newValue, forKey: "hasRequestedLocationAuthorization") }
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestAuthorisation(always: Bool = false) {
        if hasRequestedAuthorization { return }
        if always {
            manager.requestAlwaysAuthorization()
        } else {
            manager.requestWhenInUseAuthorization()
        }
        hasRequestedAuthorization = true
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            self.manager.startUpdatingLocation()
        default:
            isAuthorized = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.region.center = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
    
    func getCurrentLocation() async -> CLLocation? {
        guard isAuthorized else { return nil }
        
        return await withCheckedContinuation { continuation in
            guard let location = manager.location else {
                continuation.resume(returning: nil)
                return
            }
            continuation.resume(returning: location)
        }
    }
}
