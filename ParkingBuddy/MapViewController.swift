//
//  MapViewController.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 11..
//

import UIKit
import Mapbox
import MapboxSearch

protocol AddLocationDelegate {
    func addLocation(parkingSpotData: ParkingSpotData)
}

class MapViewController: UIViewController, MGLMapViewDelegate {

    var delegate: AddLocationDelegate?
    var mapView: MGLMapView!
    var selectedLocation: CLLocationCoordinate2D?
    let geoCoder = SearchEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapUtil.createMapView(sender: self, view: view)
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        mapView.setZoomLevel(3, animated: false)
        view.addSubview(mapView)
        addTapRecognizer()
        createNavigateBackButton()
        createFooter()
        createResetLocationButton()
        createAddLocationButton()
    }
    
    @objc func resetLocationButtonTapped(_ sender: UIButton) {
        mapView.userTrackingMode = .follow
    }
    
    @objc func navigateBackButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addLocationButtonTapped(sender: UIButton) {
        if selectedLocation != nil {
            let reverseGeoCodingOptions = SearchEngine.ReverseGeocodingOptions(point: self.selectedLocation!)
            geoCoder.reverseGeocoding(options: reverseGeoCodingOptions) { response in
                do {
                    let result = try response.get().first
                    let address = result?.address?.formattedAddress(style: .medium)
                    if address == nil {
                        throw NSError()
                    }
                    let rawLocation = "\(self.selectedLocation!.latitude):\(self.selectedLocation!.longitude)"
                    let parkingSpot = ParkingSpotData(address: address!, details: "", date: Date(), rawLocation: rawLocation)
                    self.delegate?.addLocation(parkingSpotData: parkingSpot)
                } catch {
                     let dialogMessage = UIAlertController(title: "👀", message: "No address found in your area!", preferredStyle: .alert)
                     dialogMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                     self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc @IBAction func handleMapTap(sender: UITapGestureRecognizer) {
        let tapPoint: CGPoint = sender.location(in: mapView)
        let tapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: nil)
        addMarker(selectedLocation: tapCoordinate)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var image = mapView.dequeueReusableAnnotationImage(withIdentifier: "place")
        if image == nil {
            image = MGLAnnotationImage(image: UIImage(named: "location_pin")!, reuseIdentifier: "place")
        }
        return image
    }
    
    func addTapRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        
        if mapView.gestureRecognizers != nil {
            for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
                singleTap.require(toFail: recognizer)
            }
        }
        mapView.addGestureRecognizer(singleTap)
    }
    
    func addMarker(selectedLocation coordinate: CLLocationCoordinate2D) {
        if mapView.annotations?.count != nil, let existingAnnotations = mapView.annotations {
            mapView.removeAnnotations(existingAnnotations)
        }
        
        let selectedLocation = MGLPointAnnotation()
        selectedLocation.coordinate = coordinate
        mapView.addAnnotation(selectedLocation)
    
        self.selectedLocation = coordinate
    }
    
    func createResetLocationButton() {
        let resetLocationButton = UIButton()
        resetLocationButton.addTarget(self, action: #selector(resetLocationButtonTapped), for: .touchUpInside)
        resetLocationButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        resetLocationButton.layer.shadowRadius = 5
        resetLocationButton.layer.shadowOpacity = 0.3
       
        resetLocationButton.isOpaque = true
        resetLocationButton.setBackgroundImage(UIImage(named: "location_icon"), for: .normal)

        view.addSubview(resetLocationButton)
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resetLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            resetLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            resetLocationButton.widthAnchor.constraint(equalToConstant: 30),
            resetLocationButton.heightAnchor.constraint(equalToConstant: 30)
        ])
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
    
    func createAddLocationButton() {
        let addButton = UIButton()
        addButton.backgroundColor = UIColor.white
        addButton.setTitle("ADD LOCATION", for: .normal)
        addButton.setTitleColor(UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1), for: .normal)
        addButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        addButton.layer.cornerRadius = 25
        addButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        addButton.layer.shadowRadius = 4
        addButton.layer.shadowOpacity = 0.3
        addButton.addTarget(self, action: #selector(addLocationButtonTapped), for: .touchUpInside)
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addButton.widthAnchor.constraint(equalToConstant: 230),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
