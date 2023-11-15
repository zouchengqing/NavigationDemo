//
//  ViewController.swift
//  NavigationDemo
//
//  Created by qing on 2023/11/15.
//

import UIKit
import SnapKit
import GoogleMaps
import GooglePlaces
import SwifterSwift

class MapViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    
    var mapView: GMSMapView!
    let infoMarker = GMSMarker()
    var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var startLocation: CLLocation?
    var selectedDestination: CLLocationCoordinate2D?
    var isNavigating = false
    var tripStartTimer: Date?
    
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    
//    var likelyPlaces: [GMSPlace] = []
//
//    var selectedPlace: GMSPlace?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        placesClient = GMSPlacesClient.shared()
        setupLocationManager()
        setupMapView()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.distanceFilter = 50
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
//    func setupPlacesClient() {
//        placesClient = GMSPlacesClient.shared()Z
//    }
    
    func setupMapView() {
        let position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        let options = GMSMapViewOptions()
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        options.camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: zoomLevel)
        mapView = GMSMapView(options: options)
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        stackView.insertArrangedSubview(mapView, at: 0)
        mapView.isHidden = true
    }

//    func listLikelyPlaces() {
//        likelyPlaces.removeAll()
//
//        let placeFields: GMSPlaceField = [.name, .coordinate]
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { placeLikelyhoods, error in
//            guard error == nil else {
//                print("Current Place error: \(error!.localizedDescription)")
//                return
//            }
//            guard let placeLikelyhoods = placeLikelyhoods else {
//                print("No places found.")
//                return
//            }
//            for likelyhood in placeLikelyhoods {
//                let place = likelyhood.place
//                self.likelyPlaces.append(place)
//            }
//        }
//    }
    
    // 设置在地图上的目的地
    func setDestinationOnMap() {
        // TODO: 实现允许用户在地图上选择目的地的代码
        
    }
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        if let destination = selectedDestination {
            isNavigating = true
            tripStartTimer = Date()
            startLocation = locationManager.location
            
            // TODO: 实现启动导航朝向选择的目的地的代码
        } else {
            // TODO: 显示错误或提示用户选择目的地
        }
    }
    
    // TODO: 停止导航并显示行程摘要的函数
    func stopNavigation() {
        isNavigating = false
        
        // 实现显示行程摘要的代码
    }
    
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("didTapAt coordinate: \(coordinate)")
        bottomView.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("didTap marker: \(marker)")
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print("didTap overlay: \(overlay)")
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print("didTapPOIWithPlaceID: \(placeID), name: \(name), location: \(location)")
        
//        infoMarker.snippet = placeID
//        infoMarker.position = location
//        infoMarker.title = name
//        infoMarker.opacity = 0;
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
//        mapView.selectedMarker = infoMarker
        
        
        bottomView.isHidden = false
        destinationLabel.text = name
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = locationManager.location!.distance(from: location)
        distanceLabel.text = "距你 \(distance.int) 米"
    }
    
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("Location: \(location)")
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
//            mapView.animate(to: camera)
        }
        
//        listLikelyPlaces()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
        
        // Handle authorization status
        switch manager.authorizationStatus {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // deprecated iOS14
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
}
