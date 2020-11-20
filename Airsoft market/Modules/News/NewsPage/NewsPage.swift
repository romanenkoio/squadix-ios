//
//  NewsPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import AudioToolbox


protocol UpdateFeedDelegate: class {
    func deleteFromFeed(id: Int, type: NewsType)
    func updateFeed(type: NewsType)
}

enum NewsType {
    case feed
    case userFeed
    case event
    case userEvent
    case feedFavorite
    case eventFavorite
    case none
}

class NewsPage: BaseViewController {
    let segmentController = UISegmentedControl(items: ["Новости", "События"])
    
    var newsData: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var eventData: [Event] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var contentType: NewsType?
    var feedProfileID: Int?
    
    private var refreshControl = UIRefreshControl()
 
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureUI()
        if contentType == nil {
            contentType = .feed
        }
        guard let type = contentType else { return }
        loadData(content: type)
        getCurrentProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        networkManager.getModeratingProducts() { [weak self] moderatingProducts in
            UIApplication.shared.applicationIconBadgeNumber = moderatingProducts.count
            if let tabItems = self?.tabBarController?.tabBar.items {
                let tabItem = tabItems[1]
                tabItem.badgeValue = moderatingProducts.count == 0 ? nil : "\(moderatingProducts.count)"
            }
        } failure: { error in
            print("[NETWORK] Moderating products \(error)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        feedProfileID = nil
        segmentController.isHidden = false
    }
    
    private func configureUI() {
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        addPostButton.makeRound()
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.isHidden = false
        }
        
        if feedProfileID != nil {
            segmentController.isHidden = true
            segmentController.selectedSegmentIndex = 0
            title = "Новости пользователя"
        }
        
        addPostButton.isHidden = feedProfileID != nil
    }
    
    @objc func refresh() {
        page = 0
        tableView.reloadData()
        isLoadinInProgress = false
        newsData = []
        eventData = []
        refreshControl.endRefreshing()
        loadData(content: (contentType == nil ? .feed : contentType)!)
    }
    
    @IBAction func addAction(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Выберите тип поста", preferredStyle: .actionSheet)
        
        let video = UIAlertAction(title: "Видео", style: .default, handler: { _ in
            let vc = VCFabric.getNewPostPage()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let post = UIAlertAction(title: "Пост", style: .default, handler: { _ in
            self.navigationController?.pushViewController(VCFabric.addTextPostPage(), animated: true)
        })
        
        let event = UIAlertAction(title: "Событие", style: .default, handler: { _ in
            let vc = VCFabric.addEventPage()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let cancel = UIAlertAction(title: "Назад", style: .cancel, handler: nil)
        
        alert.addAction(video)
        alert.addAction(post)
        alert.addAction(event)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

//MARK: Feed service
extension NewsPage {
    private func loadData(content: NewsType) {
        spinner.startAnimating()
        switch content {
        case .feed:
            loadPosts()
        case .userFeed:
            loadUserPosts()
        case .event:
            loadEvents()
        case .userEvent:
            loadUserEvent()
        case .feedFavorite:
            loadFavoritePosts()
        case .eventFavorite:
            loadFavoriteEvents()
        case .none:
            print("Undefined content type")
        }
        isLoadinInProgress = true
    }
    
    private func loadPosts() {
        if page == 0 {
            newsData = []
            tableView.reloadData()
        }
        
        guard !isLoadinInProgress else { return }
        networkManager.loadPosts(page: page) { [weak self] (posts, error) in
            guard let data = posts, let newsPosts = data.content  else {
                print(error?.message as Any)
                return
            }
            guard let sSelf = self else { return }
            sSelf.spinner.stopAnimating()
            
            if newsPosts.count != 0 {
                sSelf.tableView.beginUpdates()
                
                for item in newsPosts {
                    sSelf.newsData.append(item)
                    sSelf.tableView.insertRows(at: [IndexPath(item: sSelf.newsData.count - 1, section: 0)], with: .bottom)
                }
                
               
                sSelf.tableView.endUpdates()
                sSelf.isLoadinInProgress = false
                self?.page += 1
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
            
            if newsPosts.count != 0 {
                sSelf.tableView.beginUpdates()
                
                for item in newsPosts {
                    sSelf.newsData.append(item)
                    sSelf.tableView.insertRows(at: [IndexPath(item: sSelf.newsData.count - 1, section: 0)], with: .bottom)
                }
                
                sSelf.tableView.endUpdates()
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
    
    private func loadFavoritePosts() {
        
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
            
            if events.count != 0 {
                var indexPathes: [IndexPath] = []
                sSelf.tableView.beginUpdates()
                
                for item in events {
                    sSelf.eventData.append(item)
                    indexPathes.append(IndexPath(item: sSelf.eventData.count - 1, section: 0))
                }
                
                sSelf.tableView.insertRows(at: indexPathes, with: .automatic)
                sSelf.tableView.endUpdates()
                sSelf.isLoadinInProgress = false
                self?.page += 1
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
    
    private func loadUserEvent() {
        
    }
    
    private func loadFavoriteEvents() {
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 10
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            guard let type = contentType else { return }
            loadData(content: type)
        }
    }
}

extension NewsPage {
    private func setup() {
        title = "Новости"
        
        tableView.setupDelegateData(self)
        tableView.registerCell(NewsCell.self)
        
        self.navigationItem.titleView = segmentController
        segmentController.selectedSegmentIndex = 0
        segmentController.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        segmentController.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30.0)
        segmentController.addTarget(self, action: #selector(segmentWasChanged), for: .valueChanged)
    }
    
    @objc func segmentWasChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            title = "Новости"
            contentType = .feed
            newsData = []
            page = 0
        } else if segmentController.selectedSegmentIndex == 1 {
            contentType = .event
            eventData = []
            page = 0
            title = "События"
        }
        guard let type = contentType else { return }
        loadData(content: type)
    }
}


extension NewsPage: UIContextMenuInteractionDelegate {
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            guard let inter = interaction as? ObjectInteraction else { return nil }
            let vc = VCFabric.imagePreview()
            guard let post = inter.object as? Post, let pic = post.authorAvatarUrl else { return nil }
            vc.imageUrl = pic
            return vc
        }) { _ -> UIMenu? in
            
            let favorite = UIAction(title: "Перейти в профиль", image: UIImage(named: "profile")) { _ in
                guard let inter = interaction as? ObjectInteraction, let post = inter.object as? Post else { return }
                self.navigationController?.pushViewController(VCFabric.getProfilePage(for: post.authorID), animated: true)
            }
            
            if let sPost = interaction as? ObjectInteraction, let post = sPost.object as? Post, post.authorAvatarUrl != nil {
                let save = UIAction(title: "Сохранить фото", image: UIImage(systemName: "square.and.arrow.down")) { _ in
                    guard let inter = interaction as? ObjectInteraction, let post = inter.object as? Post else { return }
                    guard let pic = post.authorAvatarUrl else { return }
                    let image = UIImage()
                    image.loadFromURL(from: pic, completition: { image in
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }) { error in
                        PopupView(title: "Ошибка сохранения", subtitle: error, image: UIImage(named: "cancel")).show()
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
        if let error = error {
            PopupView(title: "Ошибка сохранения", subtitle: error.localizedDescription, image: UIImage(named: "cancel")).show()
        } else {
            PopupView(title: "Сохранено", subtitle: "", image: UIImage(named: "confirm")).show()
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
                self?.navigationController?.pushViewController(VCFabric.getNewsShowPage(post: post), animated: true)
            }failure: { _ in
                PopupView.init(title: "", subtitle: "Новость не найдена", image: UIImage(named: "cancel")).show()
            }
        } else if url.path.contains("/events/") {
            networkManager.getEventByID(postID: id) { [weak self] event in
                self?.navigationController?.pushViewController(VCFabric.getEventShowPage(event: event), animated: true)
            } failure: { _ in
                PopupView.init(title: "", subtitle: "Событие не найдено", image: UIImage(named: "cancel")).show()
            }
        }
    }
}
