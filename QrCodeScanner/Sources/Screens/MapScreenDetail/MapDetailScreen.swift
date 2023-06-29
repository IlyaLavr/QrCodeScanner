//
//  MapDetailScreen.swift
//  QrCodeScanner
//
//  Created by Илья on 11.04.2023.
//

import UIKit
import MapKit

protocol MapDetailScreenProtocol: AnyObject {
    func setupCodeOnMap(latitude: Double, longitude: Double, name: String)
}

class MapDetailScreen: UIViewController {
    
    var presenter: MapScreenDetailProtocol?
    
    // MARK: - Elements
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        return map
    }()
    
    private lazy var buttonLocation: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "location.circle.fill")?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(location), for: .touchUpInside)
        return button
    }()
    
    var locationManager: CLLocationManager = {
        let location = CLLocationManager()
        location.requestWhenInUseAuthorization()
        return location
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        locationManager.delegate = self
        presenter?.setupCoordinatesView()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(mapView)
        view.addSubview(buttonLocation)
    }
    
    private func makeConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonLocation.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-60)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.width.equalTo(80)
        }
    }
    
    // MARK: - Actions
    
    @objc func location() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - Functions
    
    func checkLocationServices() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }
    }
}

    // MARK: - Extensions

extension MapDetailScreen: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
    }
}

extension MapDetailScreen: MapDetailScreenProtocol {
    func setupCodeOnMap(latitude: Double, longitude: Double, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        let annotations = MKPointAnnotation()
        annotations.title = name
        annotations.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotations)
    }
}
