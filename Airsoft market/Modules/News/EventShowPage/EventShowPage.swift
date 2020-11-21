//
//  EventShowPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import CoreLocation
import ImageSlideshow
import Moya
import EventKit

enum EventMenuPoint {
    case images
    case authorInfo
    case decription
    case eventDate
    case eventCoordinates
    case startCoordinates
    case region
    case starteEventTime
    case eventTime
    case like
    
    static func getManuForEvent(event: Event) -> (menu: [[EventMenuPoint]], headers: [String]) {
        let authorSection: [EventMenuPoint] = [ .authorInfo, .images]
        let firstSection: [EventMenuPoint] = [.eventTime, .starteEventTime, .eventCoordinates, .startCoordinates]
        let secondSection: [EventMenuPoint] =  [.decription]
        let likeSection: [EventMenuPoint] = [.like]
        if event.isPreview {
            return ([authorSection, firstSection, secondSection], ["", "Координаты", "Описание"])
        }
        return ([authorSection, firstSection, secondSection, likeSection], ["", "Координаты", "Описание", ""])
    }
}

class EventShowPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var calendarButton: UIButton!
    
    var likeAction: Cancellable? = nil
    lazy var service = NetworkManager()
    lazy var eventStore = EKEventStore()
    weak var delegate: UpdateFeedDelegate?
    weak var likeDelegate: LikeDelegate?
    var event: Event?
    var menu: [[EventMenuPoint]] = []
    var sectionDescription: [String] = []
    var isPreview = false
    var previewImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let event = event else { return }
        let menuInfo = EventMenuPoint.getManuForEvent(event: event)
        menu = menuInfo.menu
        title = event.shortDescription
        sectionDescription = menuInfo.headers
        tableView.setupDelegateData(self)
        tableView.registerCell(ActionCell.self)
        tableView.registerCell(SimpleTextCell.self)
        tableView.registerCell(SlideShowCell.self)
        tableView.registerCell(AuthorCell.self)
        tableView.registerCell(LikeCell.self)
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: moreButton),
                                               UIBarButtonItem(customView: contactButton),
                                               UIBarButtonItem(customView: calendarButton)],
                                              animated: true)
        
        moreButton.isHidden = event.authorID != KeychainManager.profileID
        contactButton.isHidden = event.authorID == KeychainManager.profileID
    }
    
    @IBAction func contactAction(_ sender: Any) {
        guard let event = event else { return }
        spinner.startAnimating()
        service.getUserById(id: event.authorID) { (profile, error) in
            guard let profile = profile else {
                print(error as Any)
                self.spinner.stopAnimating()
                return
            }
            if let phone = profile.phone {
                self.spinner.stopAnimating()
                let url = "tel://\(phone)"
                guard let contactUrl = URL.init(string: url) else { return }
                UIApplication.shared.open(contactUrl)
                
            } else {
                self.spinner.stopAnimating()
                return
            }
        }
    }
    
    
    @IBAction func saveEventInCalendar(_ sender: Any) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                let currentCalendar = Calendar.current
                guard let event = self.event, let eventStartDate = event.startTime, let eventEndDate = currentCalendar.date(byAdding: .hour, value: 5, to: event.startTime) else { return }
                
                let predicate = self.eventStore.predicateForEvents(withStart: eventStartDate, end: eventEndDate, calendars: nil)
                let existingEvents = self.eventStore.events(matching: predicate)
                for singleEvent in existingEvents {
                    if singleEvent.title == "Не забудь зарядить аккумуляторы к игре!" && singleEvent.startDate == eventStartDate {
                        DispatchQueue.main.async {
                            PopupView(title: "", subtitle: "Уже было добавлено в календарь.", image: UIImage(named: "cancel")).show()
                        }
                        return
                    }
                }
                
                var gameCalendar: EKCalendar?
                
                if self.eventStore.calendars(for: .event).filter({$0.title == "Страйкбольные игры"}).count == 0 {
                    let newCalendar = EKCalendar(for: .event, eventStore: self.eventStore)
                    newCalendar.title = "Страйкбольные игры"
                    guard let source = self.eventStore.defaultCalendarForNewEvents?.source else { return }
                    newCalendar.source = source
                    guard let _ = try? self.eventStore.saveCalendar(newCalendar, commit: true) else { return }
                    gameCalendar = newCalendar
                } else {
                    guard let calendar = self.eventStore.calendars(for: .event).filter({$0.title == "Страйкбольные игры"}).first else { return }
                    gameCalendar = calendar
                    let calendarEvent = EKEvent(eventStore: self.eventStore)
                    calendarEvent.title = "Не забудь зарядить аккумуляторы к игре!"
                    calendarEvent.addAlarm(EKAlarm(relativeOffset: -86400))
                    calendarEvent.startDate = event.startTime
                    calendarEvent.isAllDay = false
                    calendarEvent.notes = "\(event.shortDescription ?? "") \nПодробнее в приложении Squadix: \nhttps://squadix.co/events/\(event.id)"
                    calendarEvent.endDate = currentCalendar.date(byAdding: .hour, value: 5, to: event.startTime)
                    calendarEvent.calendar = gameCalendar
                    do {
                        try self.eventStore.save(calendarEvent, span: .thisEvent, commit: true)
                        DispatchQueue.main.async {
                            PopupView(title: "", subtitle: "Сохранено в календарь", image: UIImage(named: "confirm")).show()
                        }
                    } catch let error {
                        print(error)
                    }
                }
            } else {
                self.showAlert(title: "Нет доступа к календарю")
            }
        }
    }
    
    
    @IBAction func moreButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           
           alert.addAction(UIAlertAction(title: "Редактировать", style: .default) { _ in
              
           })
           
           alert.addAction(UIAlertAction(title: "Удалить событие", style: .destructive) { [weak self] _ in
               self?.spinner.startAnimating()
               let service = NetworkManager()
               guard let event = self?.event else { return }
               service.deleteEvent(id: event.id, completion: {
                   self?.spinner.stopAnimating()
                self?.delegate?.deleteFromFeed(id: event.id, type: .event)
                   self?.navigationController?.popViewController(animated: true)
               }) { error in
                   self?.spinner.stopAnimating()
                   print("Error: \(error ?? "unknown")")
               }
           })
           
           alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
           present(alert, animated: true)
    }
    
}

extension EventShowPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventShowPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
        let type = menu[indexPath.section][indexPath.row]
        
        switch type {
        case .images:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SlideShowCell.self), for: indexPath)
            if let imageCell = cell as? SlideShowCell {
                imageCell.imageSlideshow.setupView()
                if isPreview {
                    var images: [InputSource] = []
                    for item in previewImages {
                        images.append(ImageSource(image: item))
                    }
                    imageCell.imageSlideshow.setImageInputs(images)
                } else {
                    guard let images = event?.imageUrls else { return cell }
                    imageCell.imageSlideshow.setupImagesWithUrls(images)
                }
                imageCell.action = {
                    imageCell.imageSlideshow.presentFullScreenController(from: self)
                }
                return imageCell
            }
        case .authorInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AuthorCell.self), for: indexPath)
            if let profileCell = cell as? AuthorCell {
                guard let id = event?.authorID else { return cell }
                profileCell.authorName.text = event?.authorName
                if ((event?.isPreview) != nil) {
                    profileCell.postDateLabel.text = Date().dateToHumanString()
                } else {
                    profileCell.postDateLabel.text = event?.createdAt.dateToHumanString()
                }
                
                profileCell.action = { [weak self] in
                    self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
                }
                
                let manager = NetworkManager()
                manager.getUserById(id: id) { profile, _ in
                    guard let avatar = profile?.profilePictureUrl else { return }
                    profileCell.profileAvatarImage.loadImageWith(avatar)
                    if self.isPreview {
                        profileCell.authorName.text = profile?.profileName
                        profileCell.postDateLabel.text = Date().dateForEvent()
                    }
                }
                return profileCell
            }
        case .decription:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                profileCell.simpleTextLabel.textAlignment = .justified
                profileCell.setupTextWith(event?.description ?? "Что-то пошло не так, описание отсутствует")
                return profileCell
            }
        case .eventDate:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let evDate = event?.eventDate {
                    profileCell.setupTextWith(evDate.dateForEvent())
                }
                return profileCell
            }
        case .eventCoordinates:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
            if let profileCell = cell as? ActionCell {
                guard let latitude = event?.eventLatitude, let longitude = event?.eventLongitude else {
                    return cell
                }
                guard let address = event?.eventAdress else { return cell }
                profileCell.actionDescription.text = "Площадка: \(address)"
                profileCell.action = { [weak self] in
                    let vc = VCFabric.getMapPage()
                    vc.latitude = latitude
                    vc.longitude = longitude
                    vc.title = "Площадка"
                    if let adress = self?.event?.eventAdress {
                        vc.adress = adress
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }
                return profileCell
            }
        case .startCoordinates:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
            if let profileCell = cell as? ActionCell {
                guard let latitude = event?.eventStartLatitude, let longitude = event?.eventStartLongitude else {
                    return cell
                }
                guard let address = event?.eventStartAdress else { return cell }
                profileCell.actionDescription.text = "Точка сбора: \(address)"
                profileCell.action = { [weak self] in
                    let vc = VCFabric.getMapPage()
                    vc.latitude = latitude
                    vc.longitude = longitude
                    vc.title = "Точка сбора"
                    if let adress = self?.event?.eventStartAdress {
                        vc.adress = adress
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return profileCell
            }
        case .region:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let region = event?.region {
                    profileCell.setupTextWith(region)
                }
                
                return profileCell
            }
        case .starteEventTime:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                guard let time = event?.startTime.timeForEvent() else { return cell }
                profileCell.simpleTextLabel.text = "Время сбора: \(time)"
                
                return profileCell
            }
        case .eventTime:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                guard let date = event?.eventDate.dateForEvent() else { return cell }
                profileCell.simpleTextLabel.text = "Дата игры: \(date)"
                
                return profileCell
            }
        case .like:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LikeCell.self), for: indexPath)
            if let profileCell = cell as? LikeCell {
                profileCell.selectionStyle = .none
                
                guard let event = self.event else {
                    return cell
                }
                profileCell.likeImage.setImage(UIImage(named: event.isLiked ? "like_fill" : "like"), for: .normal)
                profileCell.likeCount.text = "\(event.likesCount)"
                profileCell.action = { [weak self] in
                    if self?.likeAction != nil {
                        print("LikeAction canceled")
                        return
                    }
                    self?.likeAction = self?.networkManager.toggleLike(postID: event.id, type: .event, completion: { event in
                        self?.event?.likesCount = event.likesCount
                        self?.event?.isLiked = event.isLiked
                        self?.generator.notificationOccurred(.success)
                        self?.tableView.reloadData()
                        self?.likeDelegate?.updateLike(inEvent: self?.event)
                        self?.likeAction = nil
                    })
                }
                return profileCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDescription[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 3:
            return 0
        default:
            return 40
        }
    }
}
