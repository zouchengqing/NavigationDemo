//
//  ViewController.swift
//  NavigationDemo
//
//  Created by qing on 2023/11/15.
//

import UIKit
import SnapKit
import GoogleMaps



class MapViewController: UIViewController {

    var mapView: GMSMapView!
    @IBOutlet weak var startButton: UIButton!
    
    var locationManager: CLLocationManager!
    var startLocation: CLLocation?
    var selectedDestination: CLLocationCoordinate2D?
    var isNavigating = false
    var tripStartTimer: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.distanceFilter = 50
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // setup mapView
        let position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 6.0)
        mapView = GMSMapView(options: options)
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // setup marker
        let marker = GMSMarker()
        marker.position = position
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

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
    
    
    
}

// MARK: -

extension MapViewController: CLLocationManagerDelegate {
    
}
