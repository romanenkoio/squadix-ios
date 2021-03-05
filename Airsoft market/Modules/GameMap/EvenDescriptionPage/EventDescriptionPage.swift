//
//  EventDescriptionPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 5.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

protocol EventInfoDelegate: class {
    func showEvent(event: Event)
    func showProfile(id: Int)
}

class EventDescriptionPage: BaseViewController {

    @IBOutlet weak var routeButton: OliveButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var selectotView: UIView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var previesButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var indicateLabel: UILabel!
    @IBOutlet var mainView: UIView!
    
    weak var delegate: EventInfoDelegate?
    private var currentEventIndex: Int = 0
    var events: [Event] = []
    
    private var isYandexAvalible: Bool {
        return UIApplication.shared.canOpenURL(URL.init(string: "yandexnavi://")!)
    }
    
    private var isGoogleMapsAvalible: Bool {
        return UIApplication.shared.canOpenURL(URL.init(string: "comgooglemaps://")!)
    }
   
    private var isRouteVisible: Bool {
        return isYandexAvalible && isGoogleMapsAvalible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        let tap =  UITapGestureRecognizer(target: self, action: #selector(tapView))
        mainView.addGestureRecognizer(tap)
        routeButton.isHidden = !isRouteVisible
        selectotView.isHidden = events.count == 1
        currentEventIndex = 0
        configureEvent(event: events[currentEventIndex])
    }
    
    func configureEvent(event: Event) {
        authorName.text = event.authorName
        if let avatarUrl = event.authorAvatarURL {
            avatarImage.loadImageWith(avatarUrl)
        }
        descriptionLabel.text = event.shortDescription
        eventTimeLabel.text = event.startTime.dateForEvent()
        indicateLabel.text = "\(currentEventIndex + 1) из \(events.count)"
    }
    
    @objc func tapView() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func showEventAction(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let index = self?.currentEventIndex, let event = self?.events[index] else { return }
            self?.delegate?.showEvent(event: event)
        }
    }
    
    @IBAction func showAuthorProfile(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let index = self?.currentEventIndex, let event = self?.events[index] else { return }
            self?.delegate?.showProfile(id: event.authorID)
        }
    }
    
    
    @IBAction func switchEvent(_ sender: UIButton) {
        if sender.tag == 1000 {
            if currentEventIndex > 0 {
                currentEventIndex -= 1
            }
        } else if sender.tag == 1001 {
            if currentEventIndex < events.count - 1 {
                currentEventIndex += 1
            }
        }
        
        configureEvent(event: events[currentEventIndex])
        previesButton.isEnabled = currentEventIndex != 0
        nextButton.isEnabled = currentEventIndex != events.count - 1
    }
    
    
    @IBAction func routeAction(_ sender: Any) {
                let backAction = UIAlertAction(title: "Отмена", style: .cancel)
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
                guard let latitude = self.events[currentEventIndex].eventLatitude, let longitude = self.events[currentEventIndex].eventLongitude else { return }
        
                let yandexAction = UIAlertAction(title: "Yandex навигатор", style: .default) { _ in
                    guard let url = URL.init(string: "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)") else { return }
        
                    UIApplication.shared.open(url)
                }
        
                let googleAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
                    guard let url = URL.init(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") else { return }
        
                    UIApplication.shared.open(url)
                }
        
                if isYandexAvalible {
                    alert.addAction(yandexAction)
                }
        
                if isGoogleMapsAvalible {
                    alert.addAction(googleAction)
                }
        
                if isGoogleMapsAvalible || isYandexAvalible {
                    alert.addAction(backAction)
                }
        
                self.present(alert, animated: true, completion: nil)
    }
}
