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
import GrowingTextView

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
    case comments
    case weather
    
    static func getManuForEvent(event: Event) -> (menu: [[EventMenuPoint]], headers: [String]) {
        let authorSection: [EventMenuPoint] = [ .authorInfo, .images]
        var firstSection: [EventMenuPoint] = []
        
        if event.startTime.timeIntervalSince1970 - Date().timeIntervalSince1970 < 604800 {
            firstSection = [.eventTime, .starteEventTime, .eventCoordinates, .startCoordinates, .weather]
        } else {
            firstSection = [.eventTime, .starteEventTime, .eventCoordinates, .startCoordinates]
        }
        
        let secondSection: [EventMenuPoint] =  [.decription]
        let likeSection: [EventMenuPoint] = [.like]
        let commentSection: [EventMenuPoint] = [.comments]
        
        if event.isPreview {
            return ([authorSection, firstSection, secondSection], ["", "Координаты", "Описание"])
        }
        return ([authorSection, firstSection, secondSection, likeSection, commentSection], ["", "Координаты", "Описание", "", "Комментарии"])
    }
}

class EventShowPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var calendarButton: UIButton!
    @IBOutlet weak var commentView: CommentView!
    
    var shouldScroll = false
    var likeAction: Cancellable? = nil
    lazy var eventStore = EKEventStore()
    weak var delegate: UpdateFeedDelegate?
    weak var likeDelegate: LikeDelegate?
    var event: Event?
    var menu: [[EventMenuPoint]] = []
    var sectionDescription: [String] = []
    var isPreview = false
    var previewImages: [UIImage] = []
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let event = event else { return }
        commentView.delegate = self
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
        tableView.registerCell(CommentCell.self)
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: moreButton),
                                               UIBarButtonItem(customView: contactButton),
                                               UIBarButtonItem(customView: calendarButton)],
                                              animated: true)
        
        contactButton.isHidden = event.authorID == KeychainManager.profileID
        Analytics.trackEvent("Event_view_screen")
  
        getComment()
        if commetnForScroll != 0 {
            reportScroll = { [weak self] in
                guard let index = self?.comments.firstIndex(where: { $0.id == self?.commetnForScroll}), let section = self?.menu.count  else { return }
                let indexPath = IndexPath(row: index, section: section - 1)
                self?.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                
                guard let currentCell = self?.tableView.cellForRow(at: indexPath) as? CommentCell else { return }
                currentCell.backgroundColor = .yellow
                self?.reportScroll = nil
                self?.commetnForScroll = 0
            }
        }
    }
    
 
    
    
    @IBAction func contactAction(_ sender: Any) {
        guard let event = event else { return }
        spinner.startAnimating()
        networkManager.getUserById(id: event.authorID) { (profile, error) in
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
                            self.showPopup(isError: true, title: "Уже было добавлено в календарь.")
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
                    calendarEvent.notes = "\(event.shortDescription) \nПодробнее в приложении Squadix: \nhttps://squadix.co/events/\(event.id)"
                    calendarEvent.endDate = currentCalendar.date(byAdding: .hour, value: 5, to: event.startTime)
                    calendarEvent.calendar = gameCalendar
                    do {
                        try self.eventStore.save(calendarEvent, span: .thisEvent, commit: true)
                        DispatchQueue.main.async {
                            self.showPopup(title: "Сохранено в календарь")
                        }
                    } catch let error {
                        print(error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Нет доступа к календарю")
                }
            }
        }
    }
    
    
    @IBAction func moreButton(_ sender: Any) {
        guard let id = event?.id else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if id == KeychainManager.profileID || KeychainManager.isAdmin {
            alert.addAction(UIAlertAction(title: "Удалить событие", style: .destructive) { [weak self] _ in
                self?.showDestructiveAlert(handler: {
                    self?.spinner.startAnimating()
                    guard let event = self?.event else { return }
                    self?.networkManager.deleteEvent(id: event.id, completion: {
                        self?.spinner.stopAnimating()
                        self?.delegate?.deleteFromFeed(id: event.id, type: .event)
                        self?.navigationController?.popViewController(animated: true)
                    }) { error in
                        self?.spinner.stopAnimating()
                        print("Error: \(error ?? "unknown")")
                    }
                })
            })
        }
        
        if id != KeychainManager.profileID && !KeychainManager.isAdmin {
            alert.addAction(UIAlertAction(title: "Пожаловаться", style: .destructive) { [weak self] _ in
                self?.showDestructiveAlert(handler: {
                    self?.spinner.startAnimating()
                    self?.networkManager.report(link: "https://squadix.co/events/\(id)") {
                        self?.spinner.stopAnimating()
                        self?.showPopup(title: "Отправлено.")
                    } failure: {
                        self?.showPopup(isError: true, title: "Ошибка, попробуйте позже.")
                    }
                })
            })
        }
        
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
        if menu[section].contains(.comments) {
            return comments.count
        }
        return menu[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
        
        var type = EventMenuPoint.authorInfo
        if menu[indexPath.section].contains(.comments) {
            type = .comments
        } else {
            type = menu[indexPath.section][indexPath.row]
        }
        
        guard let event = event else { return cell }
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
                    guard let images = event.imageUrls else { return cell }
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
                guard let id = event.authorID else { return cell }
                profileCell.authorName.text = event.authorName
                if event.isPreview {
                    profileCell.postDateLabel.text = Date().dateToHumanString()
                } else {
                    profileCell.postDateLabel.text = event.createdAt.dateToHumanString()
                }
                
                profileCell.action = { [weak self] in
                    self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
                }
                
                
                networkManager.getUserById(id: id) { profile, _ in
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
                profileCell.isUserInteractionEnabled = true
                profileCell.selectionStyle = .none
                profileCell.simpleTextLabel.textAlignment = .justified
                profileCell.setupTextWith(event.description)
                return profileCell
            }
        case .eventDate:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let evDate = event.eventDate {
                    profileCell.setupTextWith(evDate.dateForEvent())
                }
                return profileCell
            }
        case .eventCoordinates:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
            if let profileCell = cell as? ActionCell {
                guard let latitude = event.eventLatitude, let longitude = event.eventLongitude else {
                    return cell
                }
                guard let address = event.eventAdress else { return cell }
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
        case .weather:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
            if let weatherCell = cell as? ActionCell {

                weatherCell.actionDescription.text = "Проверить погоду"
                weatherCell.action = { [weak self] in
                    self?.spinner.startAnimating()
                    if event.startTime.timeIntervalSince1970 - Date().timeIntervalSince1970 < 432000 {
            
                        guard let lat = event.eventStartLatitude, let long = event.eventStartLongitude else { return }
                        UtilitesManager.shared.getWeather(lat: lat, long: long) { weatherData in
                            self?.spinner.stopAnimating()
                            var eventWeathert: DailyWeather? = nil
                            
                            for item in weatherData.data {
                                guard let date = item.date else { return }
                                if event.startTime.hasSame(.day, as: date) {
                                    eventWeathert = item
                                    break
                                }
                            }
                            
                            guard let finalWeather = eventWeathert else { return }
                            let vc = WeaterPopup.loadFromNib()
                            vc.weather = finalWeather
                            vc.modalTransitionStyle = .crossDissolve
                            vc.modalPresentationStyle = .overCurrentContext
                            self?.navigationController?.present(vc, animated: true)
                        }
                    }
                }
                return weatherCell
            }
        case .startCoordinates:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath)
            if let profileCell = cell as? ActionCell {
                guard let latitude = event.eventStartLatitude, let longitude = event.eventStartLongitude else {
                    return cell
                }
                guard let address = event.eventStartAdress else { return cell }
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
                if let region = event.region {
                    profileCell.setupTextWith(region)
                }
                
                return profileCell
            }
        case .starteEventTime:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                profileCell.simpleTextLabel.text = "Время сбора: \(event.startTime.timeForEvent())"
                
                return profileCell
            }
        case .eventTime:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                profileCell.simpleTextLabel.text = "Дата игры: \(event.eventDate.dateForEvent())"
                
                return profileCell
            }
        case .comments:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentCell.self), for: indexPath)
            if let commentCell = cell as? CommentCell {
                commentCell.isUserInteractionEnabled = true
                commentCell.setupCell(comment: comments[indexPath.row])
                commentCell.action = { [weak self] in
                    guard let comment = self?.comments[indexPath.row] else { return }
                    self?.networkManager.likeComment(postType: NewsType.event, commentID: comment.id, completion: { updatedComment in
                        comment.isLiked = updatedComment.isLiked
                        comment.likeCount = updatedComment.likeCount
                        self?.comments[indexPath.row] = comment
                        let indexPath = IndexPath(item: indexPath.row, section: indexPath.section)
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }, failure: {
                        self?.showPopup(isError: true, title: "Ошибка. Попробуйте позже")
                    })
                }
                
                commentCell.tapAvatarAction = { [weak self] in
                    guard let comment = self?.comments[indexPath.row] else { return }
                    self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: comment.userID), animated: true)
                }
                
                
                commentCell.reportAction = { [weak self] in
                    guard let comment = self?.comments[indexPath.row] else { return }
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    if comment.userID == KeychainManager.profileID || KeychainManager.isAdmin {
                       
                        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
                            self?.showDestructiveAlert(handler: {
                                self?.deleteComment(commentID: comment.id)
                            })
                        }))
                    }
                    
                    if comment.userID != KeychainManager.profileID {
                        alert.addAction(UIAlertAction(title: "Пожаловаться", style: .destructive, handler: { _ in
                            self?.showDestructiveAlert(handler: {
                                self?.networkManager.report(link: "https://squadix.co/events/\(event.id)?comment=\(comment.id ?? 0)") {
                                    self?.spinner.stopAnimating()
                                    self?.showPopup(title: "Отправлено.")
                                } failure: {
                                    self?.showPopup(isError: true, title: "Ошибка, попробуйте позже.")
                                }
                            })
                        }))
                    }
                  
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
                    self?.present(alert, animated: true)
                }
                return commentCell
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
                    Analytics.trackEvent(event.isLiked ? "Event_liked" : "Event_unliked")
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
        case 4:
            return comments.count == 0 ? 0 : 40
        default:
            return 40
        }
    }
}


extension EventShowPage: Commentable {
    func likeComment(commentID: Int) {
        networkManager.likeComment(postType: NewsType.event, commentID: commentID) { [weak self] comment in
            guard let section = self?.menu.count else { return }
            self?.tableView.reloadSections(IndexSet(integer: section - 1), with: .bottom)
        }
    }
    
  
    
    func getComment() {
        guard let id = event?.id else { return }
        comments = []
        networkManager.getComment(postType: NewsType.event, postID: id) { [weak self] comments in
            guard let section = self?.menu.count else { return }
            self?.comments = comments
            self?.tableView.reloadSections(IndexSet(integer: section - 1), with: .none)
            guard let sSelf = self else { return }
            if sSelf.shouldScroll {
                guard let row = self?.comments.count, let section = self?.menu.count else { return }
                sSelf.tableView.beginUpdates()
                sSelf.tableView.endUpdates()
                sSelf.tableView.scrollToRow(at: IndexPath(row: row - 1, section: section - 1), at: .none, animated: false)
                sSelf.shouldScroll = false
            }
            sSelf.reportScroll?()
        }
    }
    
    func deleteComment(commentID: Int) {
        networkManager.deleteComment(postType: NewsType.event, commentID: commentID, completion: { [weak self] in
            self?.getComment()
            self?.showPopup(title: "Удалено")
        }, failure: { [weak self] in
            self?.showPopup(isError: true, title: "Ошибка. Попробуйте позже.")
        })
    }
}

extension EventShowPage: CommentViewDelegate {
    func sendComment(commentText: String, images: [UIImage]) {
        commentView.sendCommentButton.isEnabled = false
        spinner.startAnimating()
        guard let id = event?.id else { return }
        networkManager.postComment(postType: NewsType.event, postID: id, text: commentText, images: commentView.imageData) { [weak self] in
            self?.commentView.sendCommentButton.isEnabled = true
            self?.spinner.stopAnimating()
            self?.getComment()
            self?.commentView.commentWilSend()
            self?.shouldScroll = true
        } failure: { [weak self] in
            self?.showPopup(isError: true, title: "Не удалось опубликовать комментарий. ")
            self?.spinner.stopAnimating()
            self?.commentView.sendCommentButton.isEnabled = true
        }
    }
    
    func attachFile() {
        
    }
    
    
}

