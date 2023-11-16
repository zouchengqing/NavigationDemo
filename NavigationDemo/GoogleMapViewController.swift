//
//  ViewController.swift
//  NavigationDemo
//
//  Created by qing on 2023/11/15.
//

import UIKit
import SnapKit
import GoogleMaps
import SwifterSwift
import SwiftyJSON
import GoogleNavigation

class GoogleMapViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var mapView: GMSMapView!
    let infoMarker = GMSMarker()
    
    var polyline: GMSPolyline?
    
    var locationManager: CLLocationManager!
    var startLocation: CLLocation?
    // (placeId, name, coordinate)
    var selectedDestination: (String, String, CLLocationCoordinate2D)?
    var isNavigating = false
    var tripStartTimer: Date?
    
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
//        mapView.navigator
    }
    
    // 开始按钮
    @IBAction func startButtonClicked(_ sender: UIButton) {
        checkAuthorization { authorized in
            if authorized {
                // 如果有选中目的地
                if let destination = self.selectedDestination {
                    self.mapView.isNavigationEnabled = true
                    self.mapView.settings.compassButton = true
                    self.mapView.navigator?.add(self)
                    self.locationManager.requestAlwaysAuthorization()
                    
                    
                    self.isNavigating = true
                    self.tripStartTimer = Date()
                    self.startLocation = self.locationManager.location
                    
                    // 开始导航
                    var destinations: [GMSNavigationWaypoint] = []
                    destinations.append(GMSNavigationWaypoint(placeID: destination.0, title: destination.1)!)
                    self.mapView.navigator?.setDestinations(destinations, callback: { routeStatus in
                        guard routeStatus == .OK else {
                            print("Handle route status that are not OK.")
                            return
                        }
                        self.mapView.navigator?.isGuidanceActive = true
                        self.mapView.locationSimulator?.simulateLocationsAlongExistingRoute()
                        self.mapView.cameraMode = .following
                    })
                    self.mapView.roadSnappedLocationProvider?.startUpdatingLocation()
                    
                    
                    // TODO: 实现启动导航朝向选择的目的地的代码
                } else {
                    // TODO: 显示错误或提示用户选择目的地
                }
            }
        }
    }
    
    func checkAuthorization(_ completion: @escaping (Bool) -> Void) {
        let companyName = "NavigationDemo"
        GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(withCompanyName: companyName) { termsAccepted in
            if termsAccepted {
                // 授权后台提醒通知
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
                    if !granted || error != nil {
                        print("Authorizaiton to deliver notifications was rejected.")
                    }
                }
                completion(true)
            } else {
                print("User rejects the terms and conditions.")
                completion(true)
            }
        }
    }
    
    // TODO: 停止导航并显示行程摘要的函数
    func stopNavigation() {
        isNavigating = false
        
        // 实现显示行程摘要的代码
    }
    
}

// MARK: routes 相关

extension GoogleMapViewController {
    
    // 获取路线信息
//    func getDirections(startLocation: CLLocation, destination: CLLocationCoordinate2D) {
//        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
//        let destination = "\(destination.latitude),\(destination.longitude)"
//
//        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(APIKey)"
//
//        URLSession.shared.dataTask(with: URL(string: directionURL)!) { data, response, error in
//            guard let data = data, error == nil else {
//                // 处理请求错误
//                print("Request error: \(error!.localizedDescription)")
//                return
//            }
//            do {
////                let json = try JSONSerialization.jsonObject(with: data, options: [])
////                if let jsonDict = json as? [String: Any],
////                   let routes = jsonDict["routes"] as? [[String: Any]],
////                   let route = routes.first,
////                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
////                   let points = overviewPolyline["points"] as? String {
////                    // 解码路线信息
////                    DispatchQueue.main.async {
////                        self.drawRoute(encodedPath: points)
////                    }
////                }
//                let json = try JSON(data: data)
//                if let points = json["routes"][0]["overview_polyline"]["points"].string {
//                    // 解码路线信息
//                    DispatchQueue.main.async {
//                        self.drawRoute(encodedPath: points)
//                    }
//                } else {
//                    print("返回数据格式有误：\(json)")
//                }
//            } catch {
//                // 处理 JSON 解析错误
//                print("JSON 解析错误: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
    
    // 绘制路线
    func drawRoute(path: GMSPath) {
//        let path = GMSPath(fromEncodedPath: encodedPath)
        polyline?.map = nil
        polyline = GMSPolyline(path: path)
        polyline?.strokeWidth = 3.0
        polyline?.strokeColor = .blue
        polyline?.map = mapView
    }
    
    
}

// MARK: - GMSMapViewDelegate

extension GoogleMapViewController: GMSMapViewDelegate {
    
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
        
        guard let currentLocation = locationManager.location else {
            print("Current location is nil.")
            return
        }
        bottomView.isHidden = false
        destinationLabel.text = name
        let destinationLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = currentLocation.distance(from: destinationLocation)
        distanceLabel.text = "距你 \(distance.int) 米"
        // 绘制路线
//        getDirections(startLocation: currentLocation, destination: location)
        // 选中目的地
        selectedDestination = (placeID, name, location)
    }
    
}

extension GoogleMapViewController: GMSNavigatorListener {
    
    // 到达目的地回调
    func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
        mapView.navigator?.continueToNextDestination()
        mapView.navigator?.isGuidanceActive = true
        // 绘制路线
        drawRoute(path: navigator.traveledPath)
        
        // 耗时
        if let start = tripStartTimer {
            let now = Date()
            let time = now.timeIntervalSince(start)
            print("总共耗时：\(time)")
        }
        
        // 行驶的距离
        let distance = navigator.distance(to: waypoint)
        print("行驶距离：\(distance)")
    }
    
}

// MARK: - CLLocationManagerDelegate

extension GoogleMapViewController: CLLocationManagerDelegate {
    
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
