//
//  NewsPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import AudioToolbox
import JJFloatingActionButton


protocol UpdateFeedDelegate: class {
    func deleteFromFeed(id: Int, type: NewsType)
    func updateFeed(type: NewsType)
}

enum NewsType {
    case feed
    case userFeed
    case event
}

class NewsPage: BaseViewController {
    let segmentController = UISegmentedControl(items: ["Новости", "События"])
    @IBOutlet var dashboardButton: MFBadgeButton!
    
    var newsData: [Post] = [] {
        didSet {
//            tableView.reloadData()
        }
    }
    var eventData: [Event] = [] {
        didSet {
//            tableView.reloadData()
        }
    }
    
    var contentType: NewsType = .feed
    var feedProfileID: Int?
    var totalEventPages = 0
    var totalNewsPages = 0
    
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var actionButton = JJFloatingActionButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData(content: contentType)
        getCurrentProfile()
        
        if UsersData.shared.informNevVersion {
            networkManager.getVersion { [weak self] actualBuild in
                if let deviceBuild = self?.getBuildVersion(), deviceBuild < actualBuild {
                    self?.showAlert(maintText: "", title: "Доступно обновление. Для стабильной работы приложения его необходимо обновить.", handler: {
                        if let url = URL(string: "itms-apps://apple.com/app/id1538492084") {
                            UIApplication.shared.open(url)
                        }
                    }, buttonTitle: "Обновить")
                }
            }
        }
    }

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    if feedProfileID != nil {
        segmentController.selectedSegmentIndex = 0
        title = "Новости пользователя"
    }
    if feedProfileID != nil {
        segmentController.selectedSegmentIndex = 0
        title = "Новости пользователя"
    }
    
    Analytics.trackEvent(segmentController.selectedSegmentIndex == 0 ? "News_screen" : "Event_screen")
    segmentController.isHidden = feedProfileID != nil
    dashboardButton.isHidden = feedProfileID != nil
    
    actionButton.isHidden = feedProfileID != nil
    
    networkManager.getCurrentUser { [weak self] (profile, error, id) in
        if let user = profile {
            KeychainManager.store(value: user.roles.contains(.admin) , for: .isAdmin)
            KeychainManager.store(value: user.roles.contains(.organizer) , for: .isOrganizer)
        }
        self?.configureFloatingMenu(with: profile)
        guard KeychainManager.isAdmin else { return }
        self?.networkManager.getModeratingProducts() { [weak self] moderatingProducts in
            guard let moderatingCount = moderatingProducts.totalElements else { return }
            UIApplication.shared.applicationIconBadgeNumber = moderatingProducts.totalElements
            if let tabItems = self?.tabBarController?.tabBar.items {
                let tabItem = tabItems[1]
                tabItem.badgeValue = moderatingCount == 0 ? nil : "\(moderatingCount)"
            }
        } failure: { error in
            print("[NETWORK] Moderating products \(error)")
        }
    }
}

func configureFloatingMenu(with user: Profile? = nil) {
    actionButton.items = []
    actionButton.display(inViewController: self)
    actionButton.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    actionButton.buttonColor = .mainStrikeColor
    actionButton.itemAnimationConfiguration = .popUp(withInterItemSpacing: 20, firstItemSpacing: 20)
    
    if KeychainManager.isAdmin || KeychainManager.isOrganizer {
        actionButton.addItem(title: "Событие", image: UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)) { [weak self] item in
            let vc = AddEventPage.loadFromNib()
            vc.delegate = self
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    actionButton.addItem(title: "Пост", image: UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)) { [weak self] item in
        let vc = AddTextPostPage.loadFromNib()
        vc.updatableDelegate = self
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    actionButton.addItem(title: "Видео", image: UIImage(named: "video_plus")) { [weak self] item in
        let vc = AddPostPage.loadFromNib()
        vc.delegate = self
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    actionButton.configureDefaultItem { item in
        item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        item.titleLabel.textColor = .white
        item.buttonColor = .white
        item.buttonImageColor = .black
    }
}

private func configureUI() {
    navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: dashboardButton)],
                                          animated: true)
    refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
    refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    tableView.addSubview(refreshControl)
    tableView.setupDelegateData(self)
    tableView.registerCell(NewsCell.self)
    
    self.navigationItem.titleView = segmentController
    segmentController.selectedSegmentIndex = 0
    segmentController.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
    
    segmentController.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30.0)
    segmentController.addTarget(self, action: #selector(segmentWasChanged), for: .valueChanged)
    
    if let tabBar = self.tabBarController?.tabBar {
        tabBar.isHidden = false
    }
    
    if feedProfileID != nil {
        segmentController.selectedSegmentIndex = 0
        title = "Новости пользователя"
    }
    
    segmentController.isHidden = feedProfileID != nil
    dashboardButton.isHidden = feedProfileID != nil
    
    actionButton.isHidden = feedProfileID != nil
    
    networkManager.getNotifications { [weak self] notifications in
        let count = notifications.content.filter({$0.isReaded == false}).count
        self?.dashboardButton.badgeValue = count == 0 ? "" : "\(count)"
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}

@objc func refresh() {
    page = 0
    isLoadinInProgress = false
    totalEventPages = 0
    totalNewsPages = 0
    newsData = []
    eventData = []
    tableView.reloadData()
    refreshControl.endRefreshing()
    loadData(content: contentType)
}

@IBAction func actionDasboardOpen(_ sender: Any) {
    navigationController?.pushViewController(DashboardViewController.loadFromNib(), animated: true)
    dashboardButton.badgeValue = ""
}
}

//MARK: Feed service
extension NewsPage {
    private func loadData(content: NewsType) {
        spinner.startAnimating()
        if newsData.count == 0 || eventData.count == 0 {
            tableView.reloadData()
        }
        
        switch content {
        case .feed:
            loadPosts()
        case .userFeed:
            loadUserPosts()
        case .event:
            loadEvents()
        }
        isLoadinInProgress = true
    }
    
    private func loadPosts() {
        if page == 0 {
            newsData = []
        }
        
        guard !isLoadinInProgress else { return }
        networkManager.loadPosts(page: page) { [weak self] (posts, error) in
            guard let data = posts, let newsPosts = data.content  else {
                print(error?.message as Any)
                return
            }
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            sSelf.totalNewsPages = data.totalPages
            if newsPosts.count != 0 {
                sSelf.tableView.beginUpdates()
                
                for item in newsPosts {
                    sSelf.newsData.append(item)
                    sSelf.tableView.insertRows(at: [IndexPath(item: sSelf.newsData.count - 1, section: 0)], with: .none)
                }
                
                
                sSelf.tableView.endUpdates()
                sSelf.isLoadinInProgress = false
                sSelf.page += 1
//                sSelf.tableView.reloadData()
            } else {
                sSelf.isLoadinInProgress = false
                print("[NETWORK] Загружены все посты")
            }
        }
    }
    
    private func loadUserPosts() {
        guard !isLoadinInProgress else { return }
        guard let id = feedProfileID else {
            spinner.stopAnimating()
            return
        }
        if page == 0 {
            newsData = []
            tableView.reloadData()
        }
        networkManager.getPostsByUser(page: page, id: id, completion: { [weak self] posts in
            guard  let newsPosts = posts.content  else {
                print("Could not load user posts")
                return
            }
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            sSelf.totalNewsPages = posts.totalPages
            
            if newsPosts.count != 0 {
                sSelf.tableView.beginUpdates()
                
                for item in newsPosts {
                    sSelf.newsData.append(item)
                    sSelf.tableView.insertRows(at: [IndexPath(item: sSelf.newsData.count - 1, section: 0)], with: .bottom)
                }
                
                sSelf.tableView.endUpdates()
//                sSelf.tableView.reloadData()
                sSelf.isLoadinInProgress = false
                self?.page += 1
            } else {
                sSelf.isLoadinInProgress = false
                print("[NETWORK] Загружены все посты")
            }
            
            self?.spinner.stopAnimating()
        }) { [weak self] error in
            self?.spinner.stopAnimating()
            print(error)
        }
    }
    
    private func loadEvents() {
        guard !isLoadinInProgress else {
            spinner.stopAnimating()
            return
        }
        if page == 0 {
            newsData = []
            tableView.reloadData()
        }
        
        networkManager.getEvents(page: page, completion: { [weak self] events in
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            sSelf.totalEventPages = events.totalPages
            if events.content.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in events.content {
                    sSelf.eventData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.eventData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .automatic)
                sSelf.tableView.endUpdates()
//                sSelf.tableView.reloadData()
                sSelf.isLoadinInProgress = false
                sSelf.page += 1
            } else {
                sSelf.isLoadinInProgress = false
                print(" [NETWORK] Загружены все ивенты")
                sSelf.spinner.stopAnimating()
            }
            
            self?.spinner.stopAnimating()
        }) { [weak self] error in
            self?.spinner.stopAnimating()
            print(error)
        }
    }
}

//MARK: Profile service
extension NewsPage {
    func getCurrentProfile() {
        networkManager.getCurrentUser { (profile, error, _) in
            guard let profile = profile else { return }
            KeychainManager.store(value: profile.id, for: .profileID)
        }
    }
}


//MARK: DeletePostDelegate
extension NewsPage: UpdateFeedDelegate {
    func updateFeed(type: NewsType) {
        page = 0
        switch type {
        case .feed:
            contentType = .feed
            segmentController.selectedSegmentIndex = 0
        case .event:
            contentType = .event
            segmentController.selectedSegmentIndex = 1
        default:
            print("Unknow content type to update")
        }
        
        loadData(content: type)
    }
    
    func deleteFromFeed(id: Int, type: NewsType) {
        switch type {
        case .feed:
            if let index = newsData.firstIndex(where: { $0.id == id }) {
                newsData.remove(at: index)
                tableView.reloadData()
            }
        case .event:
            if let index = eventData.firstIndex(where: { $0.id == id }) {
                eventData.remove(at: index)
                tableView.reloadData()
            }
        default:
            print("Unknow content type to delete")
        }
    } 
}

// MARK: UITableViewDataSource
extension NewsPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 0 {
            return newsData.count
        } else if segmentController.selectedSegmentIndex == 1 {
            return eventData.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsCell.self), for: indexPath)
        
        if let newsCell = cell as? NewsCell {
            newsCell.selectionStyle = .none
            if segmentController.selectedSegmentIndex == 0 {
                
                let item = newsData[indexPath.row]
                
                if #available(iOS 13.0, *) {
                    let interaction = ObjectInteraction(delegate: self)
                    interaction.object = item
                    newsCell.authorAvatar.addInteraction(interaction)
                }
                newsCell.setupNews(with: item)
                
                return newsCell
            } else if segmentController.selectedSegmentIndex == 1 {
                
                let item = eventData[indexPath.row]
                
                if #available(iOS 13.0, *) {
                    let interaction = ObjectInteraction(delegate: self)
                    interaction.object = item
                    newsCell.authorAvatar.addInteraction(interaction)
                }
                
                newsCell.setupEvent(with: item)
                return newsCell
            }
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension NewsPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if segmentController.selectedSegmentIndex == 0 {
            let vc = VCFabric.getNewsShowPage(post: newsData[indexPath.row])
            vc.delegate = self
            vc.likeDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else if segmentController.selectedSegmentIndex == 1 {
            let vc = VCFabric.getEventShowPage(event: eventData[indexPath.row])
            vc.delegate = self
            vc.likeDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            
            return nil
        }) { _ -> UIMenu? in
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "arrowshape.turn.up.right")) { _ in
                
                var url = "", message = ""
                
                switch self.segmentController.selectedSegmentIndex {
                case 0:
                    let item = self.newsData[indexPath.row]
                    message = "Поделиться новостью"
                    url = "https://squadix.co/news/\(item.id)"
                case 1:
                    let item = self.eventData[indexPath.row]
                    message = "Поделиться событием"
                    url = "https://squadix.co/events/\(item.id)"
                default:
                    print("segmentController switch error")
                }
                
                
                if let link = NSURL(string: url)
                {
                    let objectsToShare = [message,link] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
            return UIMenu(title: "", children: [share])
        }
        return configuration
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 300)) {
            switch contentType {
            case .feed, .userFeed:
                if page < totalNewsPages {
                    loadData(content: contentType)
                }
            case .event:
                if page < totalEventPages {
                    loadData(content: contentType)
                }
            }
        }
    }
}

extension NewsPage {
    @objc func segmentWasChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            CacheManager.shared.cleanCache()
            title = "Новости"
            contentType = .feed
            newsData = []
            eventData = []
            tableView.reloadData()
            page = 0
        } else if segmentController.selectedSegmentIndex == 1 {
            CacheManager.shared.cleanCache()
            contentType = .event
            newsData = []
            eventData = []
            tableView.reloadData()
            page = 0
            title = "События"
        }
        loadData(content: contentType)
    }
}


extension NewsPage: UIContextMenuInteractionDelegate {
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            guard let inter = interaction as? ObjectInteraction else { return nil }
            let vc = ImagePreviewPage.loadFromNib()
            
            guard let post = inter.object as? BasePost, let pic = post.authorAvatarURL else { return nil }
            vc.imageUrl = pic
            return vc
        }) { _ -> UIMenu? in
            
            let favorite = UIAction(title: "Перейти в профиль", image: UIImage(named: "profile")) { _ in
                guard let inter = interaction as? ObjectInteraction, let post = inter.object as? BasePost else { return }
                self.navigationController?.pushViewController(VCFabric.getProfilePage(for: post.authorID), animated: true)
            }
            
            if let sPost = interaction as? ObjectInteraction, let post = sPost.object as? Post, post.authorAvatarURL != nil {
                let save = UIAction(title: "Сохранить фото", image: UIImage(systemName: "square.and.arrow.down")) { _ in
                    guard let inter = interaction as? ObjectInteraction, let post = inter.object as? BasePost else { return }
                    guard let pic = post.authorAvatarURL else { return }
                    let image = UIImage()
                    image.loadFromURL(from: pic, completition: { image in
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }) { error in
                        self.showPopup(isError: true, title: "Ошибка сохранения")
                        print(error)
                    }
                }
                return UIMenu(title: "", children: [favorite, save])
            }
            return UIMenu(title: "", children: [favorite])
        }
        return configuration
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            self.showPopup(isError: true, title: "Ошибка сохранения")
        } else {
            self.showPopup(isError: false, title: "Сохранено")
        }
    }
}


extension NewsPage: UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
}

extension NewsPage: LikeDelegate {
    func updateLike(inPost: Post?) {
        if let index = newsData.firstIndex(where: { $0.id == inPost?.id }), let post = inPost  {
            newsData[index].likesCount = post.likesCount
            newsData[index].isLiked = post.isLiked
            tableView.reloadData()
        }
    }
    
    func updateLike(inEvent: Event?) {
        if let index = eventData.firstIndex(where: { $0.id == inEvent?.id }), let event = inEvent  {
            eventData[index].likesCount = event.likesCount
            eventData[index].isLiked = event.isLiked
            tableView.reloadData()
        }
    }
}

extension NewsPage: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return VCFabric.getNewsPage(type: .feed)
    }
    
    static func canHandle(_ deeplink: Deeplink) -> Bool {
        guard let url = deeplink.url, url.path.contains("/news/") || url.path.contains("/events/")  else { return false }
        let postID = url.path.matches(for: "[0-9]+").first
        if let postID = postID, Int(postID) != nil {
            return true
        }
        return false
    }
    
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool {
        return true
    }
    
    func handle(_ deeplink: Deeplink) {
        guard let url = deeplink.url,  let postID = url.path.matches(for: "[0-9]+").first, let id = Int(postID) else { return }
        if url.path.contains("/news/") {
            networkManager.getPostByID(postID: id) { [weak self] post in
                let vc = VCFabric.getNewsShowPage(post: post)
                if let value = url.valueOf("comment"), let commentID = Int(value)  {
                    vc.commetnForScroll = commentID
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }failure: { _ in
                self.showPopup(isError: true, title: "Новость не найдена")
            }
        } else if url.path.contains("/events/") {
            networkManager.getEventByID(postID: id) { [weak self] event in
                let vc = VCFabric.getEventShowPage(event: event)
                if let value = url.valueOf("comment"), let commentID = Int(value)  {
                    vc.commetnForScroll = commentID
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            } failure: { _ in
                self.showPopup(isError: true, title: "Событие не найдено")
            }
        }
    }
}
