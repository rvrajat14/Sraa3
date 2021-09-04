//
//  LocationService.swift
//  TaxiApp
//
//  Created by Apple on 03/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreLocation
var lastTimestamp: Date!

class LocationService: NSObject  , CLLocationManagerDelegate
{
    var locationManager : CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!

    class var shared: LocationService {
        struct Singleton {
            static let instance = LocationService()
        }
        return Singleton.instance
}

  func requestForUserLocation() {
    
        let authorizationStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
      //  self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        print("init LocationData")
        
        currentLocation = locationManager.location
    
       // currentLati = currentLocation.coordinate.latitude
       // currentLongi = currentLocation.coordinate.longitude
        
    }
    
    func isLocationPermissionEnabled() -> Bool {
        
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
        
    }
    
    // MARK: -   CLLocationManagerDelegate
    
    private func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
       // print("location updated ")
        let location = locations.last
       // print(String(format: "Latitude %+.6f, Longitude %+.6f\n", location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0))
        currentLocation = location
      //  currentLati = Float(currentLocation.coordinate.latitude)
     //   currentLongi = Float(currentLocation.coordinate.longitude)
        let dict = ["latitude":currentLocation.coordinate.latitude,"longitude":currentLocation.coordinate.longitude] as NSDictionary
      
    }
    
    
/*    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        print("updated")
        
        print("old location \(oldLocation)")
        print("new location \(newLocation)")
        currentLati = Float(currentLocation.coordinate.latitude)
        currentLongi = Float(currentLocation.coordinate.longitude)
    } */
 }

