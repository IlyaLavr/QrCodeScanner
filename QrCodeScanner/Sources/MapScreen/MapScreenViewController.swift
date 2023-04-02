//
//  MapScreenViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 03.04.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapScreenViewProtocol: AnyObject {
    
}

class MapScreenViewController: UIViewController, MapScreenViewProtocol {
    var presenter: MapScreenPresenterProtocol?
    
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
        checkLocationServices()
        locationManager.delegate = self
        fetchQrCodeOnMap()
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
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            }
        }
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    
    func fetchQrCodeOnMap() {
        if let fetchQrCodes = presenter?.fetchAllQrCodes() {
            for qrCode in fetchQrCodes {
                let annotations = MKPointAnnotation()
                annotations.title = qrCode.name
                annotations.coordinate = CLLocationCoordinate2D(latitude: qrCode.latitude, longitude: qrCode.longitude)
                mapView.addAnnotation(annotations)
            }
        }
    }
}

// MARK: - Extension

extension MapScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
                         locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
    }
}
