//
//  GameMapPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/30/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import GoogleMaps


class GameMapPage: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var eventInfoCotainer: UIView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var routeButton: OliveButton!
    @IBOutlet var calendarButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var refreshButton: UIButton!
    
    let networkManager = NetworkManager()
    var isExpand = false
    var eventsData: [Event] = []
    var filteredEventsData: [Event] = []
    var event: Event?
    var isFiltered = false
    
    var isYandexAvalible: Bool {
        return UIApplication.shared.canOpenURL(URL.init(string: "yandexnavi://")!)
    }
    var isGoogleMapsAvalible: Bool {
        return UIApplication.shared.canOpenURL(URL.init(string: "comgooglemaps://")!)
    }
    var isYandexMapsAvalible: Bool {
        return UIApplication.shared.canOpenURL(URL.init(string: "yandexmaps://")!)
    }
    var isRouteVisible: Bool{
        return isYandexAvalible && isYandexMapsAvalible && isGoogleMapsAvalible
    }
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        locationManager.requestAlwaysAuthorization()
        authorImageView.makeRound()
        
        title = "Карта игр"
        
        eventInfoCotainer.clipsToBounds = true
        eventInfoCotainer.layer.cornerRadius = 20
        eventInfoCotainer.dropShadow()
        eventInfoCotainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        triggerInfoView(shouldShow: false, duration: 0)
        eventInfoCotainer.isHidden = true
        isExpand = false
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        eventInfoCotainer.addGestureRecognizer(swipe)
        swipe.direction = .down
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: calendarButton), UIBarButtonItem(customView: refreshButton)], animated: true)
        loadEvents()
        Analytics.trackEvent("Game_map_screen")
    }
    
    @objc func swipeAction(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .down {
            triggerInfoView(shouldShow: false)
        }
    }
    
    func getMapWithEvent() {
        mapView.clear()
        var markers: [GMSMarker] = []
        
        for item in isFiltered ? filteredEventsData : eventsData {
            let marker = GMSMarker()
            guard let latitude = item.eventLatitude, let longitude = item.eventLongitude else { return }
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.map = mapView
            marker.userData = item
            if item.eventType == .some(.unknown) {
                let pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                pin.image = item.eventType.eventTypeImage
                marker.iconView = pin
            } else {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                view.backgroundColor = .white
                let pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                pin.translatesAutoresizingMaskIntoConstraints = false
             
                pin.image = item.eventType.eventTypeImage
                view.addSubview(pin)
                pin.translatesAutoresizingMaskIntoConstraints = true
                pin.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                view.makeRound()
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.gray.cgColor
                marker.iconView = view
            }
        
           
          
            marker.isTappable = true
            marker.title = item.shortDescription
            markers.append(marker)
        }
        
        if let firstPos = markers.first?.position {
            var bounds = GMSCoordinateBounds(coordinate: firstPos, coordinate: firstPos)
            for marker in markers {
                bounds = bounds.includingCoordinate(marker.position)
            }
            let insets = UIEdgeInsets(top: 60, left: 50, bottom: isExpand ? 200 : 30, right: 50)
            let update = GMSCameraUpdate.fit(bounds, with: insets)
            mapView?.animate(with: update)
            mapView.animate(toZoom: 10)
        }
    }
    
    func triggerInfoView(shouldShow: Bool, duration: Float = 0.5, event: Event = Event()) {
        eventInfoCotainer.isHidden = false
        
        if shouldShow {
            eventDateLabel.text = "Дата: \(event.eventDate.dateToHumanString())"
            eventTitleLabel.text = event.shortDescription
            authorNameLabel.text = event.authorName
            routeButton.isHidden = !isRouteVisible
            guard let userID = event.authorID else { return }
            networkManager.getUserById(id: userID) { [weak self] profile, _ in
                if let image = profile?.profilePictureUrl {
                    self?.authorImageView.loadImageWith(image)
                } else {
                    self?.authorImageView.image = UIImage(named: "avatar_placeholder")
                }
            }
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.containerHeight.priority = shouldShow ? UILayoutPriority(rawValue: 250) : UILayoutPriority(rawValue: 1000)
            self?.isExpand = !shouldShow
            self?.view.layoutIfNeeded()
        }
    }
    
    
    
    //    MARK: Actions
    @IBAction func openProfileAction(_ sender: Any) {
        guard let id = event?.authorID else { return }
        navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
    }
    
    @IBAction func expandAction(_ sender: Any) {
        triggerInfoView(shouldShow: isExpand)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        triggerInfoView(shouldShow: false)
        loadEvents()
    }
    
    @IBAction func showEventAction(_ sender: Any) {
        guard let event = event else { return  }
        navigationController?.pushViewController(VCFabric.getEventShowPage(event: event), animated: true)
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
            self.triggerInfoView(shouldShow: false)
            self.getMapWithEvent()
        })
        
        let cancelAction = UIAlertAction(title: "Назад", style: .cancel, handler: nil)
        
        alert.addAction(selectAction)
         alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func routeToEventAction(_ sender: Any) {
        let backAction = UIAlertAction(title: "Отмена", style: .cancel)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard let latitude = self.event?.eventLatitude, let longitude = self.event?.eventLongitude else { return }
        
        let yandexAction = UIAlertAction(title: "Yandex навигатор", style: .default) { _ in
            guard let url = URL.init(string: "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)") else { return }
            
            UIApplication.shared.open(url)
        }
        
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            guard let url = URL.init(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") else { return }
            
            UIApplication.shared.open(url)
        }
        
        let yandexMapAction = UIAlertAction(title: "Yandex карты", style: .default) { _ in
            guard let coordinate = self.mapView.myLocation else { return }
            guard let url = URL.init(string: "yandexmaps://maps.yandex.com/?rtext=\(coordinate.coordinate.latitude),\(coordinate.coordinate.longitude)~\(latitude),\(longitude)") else { return }
            
            UIApplication.shared.open(url)
        }
        
        if isYandexMapsAvalible {
            alert.addAction(yandexMapAction)
        }
        
        if isYandexAvalible {
            alert.addAction(yandexAction)
        }
        
        if isGoogleMapsAvalible {
            alert.addAction(googleAction)
        }
        
        if isGoogleMapsAvalible || isYandexAvalible || isYandexMapsAvalible {
            alert.addAction(backAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension GameMapPage: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let event = marker.userData as? Event else { return false }
        self.event = event
        triggerInfoView(shouldShow: true, event: event)
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
