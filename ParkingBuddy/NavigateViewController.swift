//
//  NavigateViewController.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 19..
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation

protocol RemoveLocationDelegate {
    func removeLocation(_ indexPath: IndexPath)
}

class NavigateViewController: UIViewController, MGLMapViewDelegate, NavigationViewControllerDelegate {

    var delegate: RemoveLocationDelegate?
    var indexPath: IndexPath!
    var parkingLocation: CLLocationCoordinate2D!
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapUtil.createMapView(sender: self, view: view)
        mapView.setCenter(parkingLocation, zoomLevel: 15, animated: false)
        view.addSubview(mapView)
        createFooter()
        createNavigateButton()
        createNavigateBackButton()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        let point = MGLPointAnnotation()
        point.coordinate = parkingLocation
     
        let shapeSource = MGLShapeSource(identifier: "marker-source", shape: point, options: nil)
        let shapeLayer = MGLSymbolStyleLayer(identifier: "marker-style", source: shapeSource)
     
        if let image = UIImage(named: "location_pin") {
            style.setImage(image, forName: "location_pin")
        }
        
        shapeLayer.iconImageName = NSExpression(forConstantValue: "location_pin")

        style.addSource(shapeSource)
        style.addLayer(shapeLayer)
    }
    
    public func setLocation(rawLocation: String) {
        let coordinates = rawLocation.split(separator: ":")
        parkingLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
    }
    
    @objc func navigationButtonTapped(_ sender: UIButton) {
        calculateRoute(from: mapView.userLocation!.coordinate, to: parkingLocation)
    }
    
    @objc func navigateBackButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func createFooter() {
        let footer = UILabel()
        footer.backgroundColor = UIColor.white
        
        view.addSubview(footer)
        footer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.heightAnchor.constraint(equalToConstant: 85)
        ])
    }
    
    func createNavigateButton() {
        let navigateButton = UIButton()
        navigateButton.backgroundColor = UIColor.white
        navigateButton.setTitle("NAVIGATE", for: .normal)
        navigateButton.setTitleColor(UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowRadius = 4
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigationButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(navigateButton)
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            navigateButton.widthAnchor.constraint(equalToConstant: 230),
            navigateButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func createNavigateBackButton() {
        let navigateBackButton = UIButton()
        navigateBackButton.addTarget(self, action: #selector(navigateBackButtonTapped), for: .touchUpInside)
        navigateBackButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateBackButton.layer.shadowRadius = 5
        navigateBackButton.layer.shadowOpacity = 0.3
       
        navigateBackButton.isOpaque = true
        navigateBackButton.setBackgroundImage(UIImage(named: "navigate_back"), for: .normal)

        view.addSubview(navigateBackButton)
        navigateBackButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigateBackButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            navigateBackButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            navigateBackButton.widthAnchor.constraint(equalToConstant: 30),
            navigateBackButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func calculateRoute(from originCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
        let options = NavigationRouteOptions(coordinates: [originCoordinate, destinationCoordinate], profileIdentifier: .walking)
        
        Directions.shared.calculate(options) { [weak self] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: options)
                let navigationViewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: options, navigationOptions: NavigationOptions(navigationService: navigationService))
                navigationViewController.delegate = self
                navigationViewController.modalPresentationStyle = .fullScreen
                navigationViewController.routeLineTracksTraversal = true
                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        if (!canceled) {
            self.delegate!.removeLocation(indexPath)
            self.dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true)
    }
}
