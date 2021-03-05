//
//  GameMapPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/30/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class PinRenderer: GMUDefaultClusterRenderer {
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        return cluster.count > 1 ? true : false
    }
}

class EventMarker: GMSMarker {
    let event: Event
    
    init(event: Event) {
        self.event = event
        super.init()
        guard let latitude = event.eventLatitude, let longitude = event.eventLongitude else { return }
        self.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.isTappable = true
//        self.title = event.shortDescription
        
        if event.eventType == .some(.unknown) {
            let pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            pin.image = event.eventType.eventTypeImage
            self.iconView = pin
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.backgroundColor = .white
            let pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            pin.translatesAutoresizingMaskIntoConstraints = false
            
            pin.image = event.eventType.eventTypeImage
            view.addSubview(pin)
            pin.translatesAutoresizingMaskIntoConstraints = true
            pin.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            view.makeRound()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.gray.cgColor
            self.iconView = view
        }
    }
}

class ClusterItem: NSObject, GMUClusterItem {
    let position: CLLocationCoordinate2D
    let event: Event

    init(event: Event) {
        self.event = event
        guard let latitude = event.eventLatitude, let longitude = event.eventLongitude else {
            self.position = CLLocationCoordinate2D(latitude: 53.867987582981286, longitude: 27.590943689217745)
            return
        }
        self.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class GameMapPage: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var calendarButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var refreshButton: UIButton!
    
    let networkManager = NetworkManager()
    var eventsData: [Event] = []
    var filteredEventsData: [Event] = []
    var isFiltered = false
    var clusterManager: GMUClusterManager!
    

    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureView()
        loadEvents()
        setupClusterManager()
        locationManager.requestAlwaysAuthorization()
        Analytics.trackEvent("Game_map_screen")
    }
    
    func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = PinRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
    }
    
    func configureView() {
        
        title = "Карта игр"
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: calendarButton), UIBarButtonItem(customView: refreshButton)], animated: true)
    }
    
    
    func getMapWithEvent() {
        mapView.clear()
        clusterManager.clearItems()
        var markers: [EventMarker] = []
        
        for item in isFiltered ? filteredEventsData : eventsData {
            markers.append(EventMarker(event: item))
        }
        
        markers.forEach({
            clusterManager.add(ClusterItem(event: $0.event))
        })
        clusterManager.cluster()
        
        if let firstPos = markers.first?.position {
            var bounds = GMSCoordinateBounds(coordinate: firstPos, coordinate: firstPos)
            for marker in markers {
                bounds = bounds.includingCoordinate(marker.position)
            }
            let insets = UIEdgeInsets(top: 60, left: 50, bottom:  30, right: 50)
            let update = GMSCameraUpdate.fit(bounds, with: insets)
            mapView?.animate(with: update)
            mapView.animate(toZoom: 10)
        }
    }
    
    //    MARK: Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        loadEvents()
    }
    

    @IBAction func selectCalendar(_ sender: Any) {
        
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        datePicker.minimumDate = Date()
        datePicker.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: 200)
        
        let alert = UIAlertController(title: "Выберите дату", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        let selectAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            self.isFiltered = true
            self.filteredEventsData.removeAll()
            
            for event in self.eventsData {
                if datePicker.date.compare(with: event.eventDate) {
                    self.filteredEventsData.append(event)
                }
            }
        
            self.getMapWithEvent()
        })
        
        let resetAction = UIAlertAction(title: "Сброс", style: .default, handler: { _ in
            self.isFiltered = false
            self.getMapWithEvent()
        })
        
        let cancelAction = UIAlertAction(title: "Назад", style: .cancel, handler: nil)
        
        alert.addAction(selectAction)
         alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func routeToEventAction(_ sender: Any) {
//        let backAction = UIAlertAction(title: "Отмена", style: .cancel)
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        guard let latitude = self.event?.eventLatitude, let longitude = self.event?.eventLongitude else { return }
//
//        let yandexAction = UIAlertAction(title: "Yandex навигатор", style: .default) { _ in
//            guard let url = URL.init(string: "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)") else { return }
//
//            UIApplication.shared.open(url)
//        }
//
//        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
//            guard let url = URL.init(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") else { return }
//
//            UIApplication.shared.open(url)
//        }
//
//        let yandexMapAction = UIAlertAction(title: "Yandex карты", style: .default) { _ in
//            guard let coordinate = self.mapView.myLocation else { return }
//            guard let url = URL.init(string: "yandexmaps://maps.yandex.com/?rtext=\(coordinate.coordinate.latitude),\(coordinate.coordinate.longitude)~\(latitude),\(longitude)") else { return }
//
//            UIApplication.shared.open(url)
//        }
//
//        if isYandexMapsAvalible {
//            alert.addAction(yandexMapAction)
//        }
//
//        if isYandexAvalible {
//            alert.addAction(yandexAction)
//        }
//
//        if isGoogleMapsAvalible {
//            alert.addAction(googleAction)
//        }
//
//        if isGoogleMapsAvalible || isYandexAvalible || isYandexMapsAvalible {
//            alert.addAction(backAction)
//        }
//
//        self.present(alert, animated: true, completion: nil)
    }
}

extension GameMapPage: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let eventMarker = marker as? EventMarker else { return false }
        let vc = VCFabric.getEventDescriptonPage(events: [eventMarker.event])
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        navigationController?.present(vc, animated: true)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        
    }
}

extension GameMapPage {
    private func loadEvents() {
        networkManager.getEvents(completion: { [weak self] events in
            self?.eventsData.removeAll()
            self?.eventsData = events.content
            self?.spinner.stopAnimating()
            self?.getMapWithEvent()
        }) { [weak self] error in
            self?.spinner.stopAnimating()
            print(error)
        }
    }
}

extension GameMapPage: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        print("tap cluster")
        guard let clusterEvents = cluster.items as? [ClusterItem] else { return false }
        let vc = VCFabric.getEventDescriptonPage(events: clusterEvents.map({ $0.event}))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        navigationController?.present(vc, animated: true)
        return false
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        print("tap cluster item")
        return false
    }
}

extension GameMapPage: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        switch object {
        case let clusterItem as ClusterItem:
            return EventMarker(event: clusterItem.event)
        default:
            return nil
        }
    }
}




extension GameMapPage: EventInfoDelegate {
    func showEvent(event: Event) {
        navigationController?.pushViewController(VCFabric.getEventShowPage(event: event), animated: true)
    }
    
    func showProfile(id: Int) {
        navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
    }
}
