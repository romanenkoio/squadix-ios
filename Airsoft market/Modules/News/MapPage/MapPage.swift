//
//  MapPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class MapPage: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    var latitude = 10.0
    var longitude = 10.0
    var adress = "Площадка сосновая"
    var locationManager = CLLocationManager()
    var isEventCheck = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        centreMap()
        mapView.isMyLocationEnabled = !isEventCheck
        mapView.settings.myLocationButton = !isEventCheck
        mapView.settings.compassButton = !isEventCheck
        locationManager.requestAlwaysAuthorization()
    }

    func centreMap() {
        mapView.clear()
        
        let destinationPin: GMSMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        destinationPin.title = "Адрес места назначения"
        let pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        pin.image = UIImage(named: "general")
        destinationPin.iconView = pin
        destinationPin.map = mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10)
        mapView.animate(to: camera)
        
        guard let location = mapView.myLocation else { return }
        var bounds = GMSCoordinateBounds(coordinate: location.coordinate, coordinate: location.coordinate)
        bounds = bounds.includingCoordinate(destinationPin.position)
        let insets = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.animate(with: update)
    }


}
