//
//  MapUtil.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 21..
//

import Foundation
import Mapbox

class MapUtil {
    
    public static func createMapView(sender: MGLMapViewDelegate, view: UIView) -> MGLMapView {
        let url = URL(string: "mapbox://styles/norbertnagy/cktj263oc019y17o3j7ua9swv")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.delegate = sender
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
        mapView.showsUserLocation = true
        
        return mapView
    }
    
}
