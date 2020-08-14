//
//  ContentView.swift
//  iOS14SwiftUICoreLocation
//
//  Created by Anupam Chugh on 14/08/20.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
  
  @ObservedObject var locationVM = LocationViewModel()
  
  var body: some View {
    VStack {
        Text(locationVM.locationStatus)
        Text("Latitude: \(locationVM.userLat)")
        Text("Longitude: \(locationVM.userLng)")
    }
  }
}


class LocationViewModel: NSObject, ObservableObject{
  
    @Published var userLat: Double = 0
    @Published var userLng: Double = 0
    
    @Published var locationStatus = "..."
  
    private let locationManager = CLLocationManager()
  
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func checkLocationAccuracyAllowed() {
        switch locationManager.accuracyAuthorization {
        case .reducedAccuracy:
            locationStatus = "approximate location"
        case .fullAccuracy:
            locationStatus = "accurate location"
        @unknown default:
            locationStatus = "unknown type"
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func requestLocationAuth() {

        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced

        switch locationManager.authorizationStatus() {
        case .authorizedAlways:
            locationStatus = "authorized always"
            checkLocationAccuracyAllowed()
        case .authorizedWhenInUse:
            locationStatus = "authorized when in use"
            checkLocationAccuracyAllowed()
        case .notDetermined:
            locationStatus = "not determined"
        case .restricted:
            locationStatus = "restricted"
        case .denied:
            locationStatus = "denied"
        default:
            locationStatus = "other"
        }
        
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
  
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLat = location.coordinate.latitude
        userLng = location.coordinate.longitude
   }
    
   func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        let status = manager.authorizationStatus()
        let accuracyStatus = manager.accuracyAuthorization
        
        if(status == .authorizedWhenInUse || status == .authorizedAlways){
            
            if accuracyStatus == CLAccuracyAuthorization.reducedAccuracy{
                locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "wantAccurateLocation", completion: { [self]
                    error in
                    
                    if locationManager.accuracyAuthorization == .fullAccuracy{
                        locationStatus = "Full Accuracy Location Access Granted Temporarily"
                    }
                    else{
                        locationStatus = "Approx Location As User Denied Accurate Location Access"
                    }
                    locationManager.startUpdatingLocation()
                })
            }
        }
        else{
            requestLocationAuth()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
