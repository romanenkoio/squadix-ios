//
//  MarketPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import Moya

class MarketPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var adminButton: MFBadgeButton!
    
    var searchRequest: Cancellable?
    var refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    
    var marketData: [MarketProduct] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var searchMarketData: [MarketProduct] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isSearchInProcess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по названию"
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.backgroundColor = .white
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
      
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        adminButton.isHidden = true
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        networkManager.getCurrentUser { [weak self] (profile, error, id) in
            guard let user = profile, user.roles.contains(.admin) || user.roles.contains(.moderator)  else {
                self?.adminButton.isHidden = true
                return
            }
            self?.networkManager.getModeratingProducts() { [weak self] moderatingProducts in
                self?.adminButton.isHidden = self?.profileID != nil
                self?.adminButton.badgeValue =  moderatingProducts.count == 0 ? nil : "\(moderatingProducts.count)"
                UIApplication.shared.applicationIconBadgeNumber = moderatingProducts.count
                if let tabItems = self?.tabBarController?.tabBar.items {
                    let tabItem = tabItems[1]
                    tabItem.badgeValue = moderatingProducts.count == 0 ? nil : "\(moderatingProducts.count)"
                }
            } failure: { error in
                print("[NETWORK] Moderating products \(error)")
            }
        }
    }
    
    
    @objc func refresh() {
        page = 0
        marketData = []
        loadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func routeToFiltres(_ sender: Any) {
        spinner.startAnimating()
        RealmService.updateFilters { [weak self] in
            let vc = VCFabric.getFilterPage()
            vc.delegate = self
            self?.navigationController?.pushViewController(vc, animated: true)
            self?.spinner.stopAnimating()
        }
    }
    
    @IBAction func addAnnouncementDidTap(_ sender: Any) {
        spinner.startAnimating()
        networkManager.getCategories(completion: { [weak self] categories in
            
            self?.networkManager.getCurrentUser(completion: { (profile, error, id) in
                guard let currentProfile = profile, let phone = currentProfile.phone, Validator.shared.validate(string: phone, pattern: Validator.Regexp.phone.rawValue) else {
                    self?.spinner.stopAnimating()
                    let alert = UIAlertController(title: "Ошибка", message: "Пользователи без номера не могут создавать объявления. Перейдите в настройки профиля и добавьте номер телефона.", preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Назад", style: .cancel, handler: nil)
                    
                    let updateProfilaAction = UIAlertAction(title: "Перейти в настройки профиля", style: .default, handler: { _ in
                        self?.navigationController?.pushViewController(VCFabric.getUserEditPage(isEdit: true), animated: true)
                    })
                    
                    alert.addAction(updateProfilaAction)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true)
                    return
                }
                self?.spinner.stopAnimating()
                self?.navigationController?.pushViewController(VCFabric.getAddProductPage(categories: categories.sorted(by: {$0 < $1})), animated: true)
            })
            
        }, failure: { [weak self] error in
            print("[NETWORK] \(error)")
            self?.spinner.stopAnimating()
            PopupView(title: "", subtitle: "Ошибка обновления категорий", image: UIImage(named: "cancel")).show()
        })
    }
    
    @IBAction func adminAction(_ sender: Any) {
        navigationController?.pushViewController(VCFabric.adminPage(), animated: true)
    }
    
    func loadData() {
        guard !isLoadinInProgress else {
            return
        }
        isLoadinInProgress = true
        if page == 0 {
            marketData = []
        }
        spinner.startAnimating()
        let manager = NetworkManager()
        
        if profileID != nil {
            guard let id = profileID else {
                spinner.stopAnimating()
                return
            }
            manager.getProductsByUser(page: page, id: id, completion: { [weak self] products in
                
                guard let sSelf = self else { return }
                sSelf.spinner.stopAnimating()
                
                if products.count != 0 {
                    var indexPathes: [IndexPath] = []
                    sSelf.tableView.beginUpdates()
                    
                    for item in products {
                        sSelf.marketData.append(item)
                        indexPathes.append(IndexPath(item: sSelf.marketData.count - 1, section: 0))
                    }
                    
                    sSelf.tableView.insertRows(at: indexPathes, with: .none)
                    sSelf.tableView.endUpdates()
                    sSelf.isLoadinInProgress = false
                    self?.page += 1
                } else {
                    sSelf.isLoadinInProgress = false
                    print(" [NETWORK] Загружены все товары")
                    sSelf.spinner.stopAnimating()
                }
            }) { [weak self] error in
                print(error)
                self?.spinner.stopAnimating()
            }
        } else {
            if RealmService.readFilters().filter({$0.status == true}).count == 0 {
                manager.getCategories { categories in
                    RealmService.writeFilters(categories.map({Filter(category: $0)}))
                    _ = manager.getActiveProductsWithFilters(page: self.page, completion: { [weak self] products in
                        
                        guard let sSelf = self else { return }
                        sSelf.spinner.stopAnimating()
                        
                        if products.count != 0 {
                            var indexPathes: [IndexPath] = []
                            sSelf.tableView.beginUpdates()
                            
                            for item in products {
                                sSelf.marketData.append(item)
                                indexPathes.append(IndexPath(item: sSelf.marketData.count - 1, section: 0))
                            }
                            
                            sSelf.tableView.insertRows(at: indexPathes, with: .none)
                            sSelf.tableView.endUpdates()
                            sSelf.isLoadinInProgress = false
                            self?.page += 1
                        } else {
                            sSelf.isLoadinInProgress = false
                            print(" [NETWORK] Загружены все товары")
                            sSelf.spinner.stopAnimating()
                        }
                        
                        self?.spinner.stopAnimating()
                        self?.title = "Барахолка"
                    }) {  [weak self] error in
                        print(error)
                        self?.spinner.stopAnimating()
                    }
                }
            } else {
                manager.getActiveProductsWithFilters(page: self.page, completion: { [weak self] products in
                    
                    guard let sSelf = self else { return }
                    sSelf.spinner.stopAnimating()
                    
                    if products.count != 0 {
                        var indexPathes: [IndexPath] = []
                        sSelf.tableView.beginUpdates()
                        
                        for item in products {
                            sSelf.marketData.append(item)
                            indexPathes.append(IndexPath(item: sSelf.marketData.count - 1, section: 0))
                        }
                        
                        sSelf.tableView.insertRows(at: indexPathes, with: .none)
                        sSelf.tableView.endUpdates()
                        sSelf.isLoadinInProgress = false
                        self?.page += 1
                    } else {
                        sSelf.isLoadinInProgress = false
                        print(" [NETWORK] Загружены все товары")
                        sSelf.spinner.stopAnimating()
                    }
                    
                    self?.spinner.stopAnimating()
                    self?.title = "Барахолка"
                }) {  [weak self] error in
                    print(error)
                    self?.spinner.stopAnimating()
                }
            }
         
        }
    }
}

extension MarketPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        marketData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MarketCell.self), for: indexPath)
        if let marketCell = cell as? MarketCell {
            marketCell.productNameLabel.text = marketData[indexPath.row].productName
            
            let reg = marketData[indexPath.row].productRegion == nil ? "Город не указан" : marketData[indexPath.row].productRegion
            marketCell.regionLabel.text = reg
            
            marketCell.productImage.loadImageWith(marketData[indexPath.row].picturesUrl[0])
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: marketData[indexPath.row].createdAt) {
                marketCell.productDateLabel.text = date.dateToHumanString()
            }
            
            if let price = marketData[indexPath.row].price {
                marketCell.productPriceLabel.text = "\(price) руб"
            }
            marketCell.selectionStyle = .none
            
            return marketCell
        }
        return cell
    }
}

extension MarketPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = VCFabric.getProductPage(product: marketData[indexPath.row])
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 10
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            
          loadData()
            
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            
            return nil
        }) { _ -> UIMenu? in
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "arrowshape.turn.up.right")) { _ in
                
                let message = "Поделиться объявлением "
                let url = "https://squadix.co/products/\(self.marketData[indexPath.row].postID)"
                
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
}

extension MarketPage {
    func setup() {
        addProductButton.makeRound()
        tableView.setupDelegateData(self)
        tableView.registerCell(MarketCell.self)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: settingsButton),
                                                      UIBarButtonItem(customView: adminButton)],
                                                     animated: true)
        settingsButton.isHidden = profileID != nil
        adminButton.isHidden = profileID != nil
        addProductButton.isHidden = profileID != nil
    }
}

extension MarketPage: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
            if let searchText = searchController.searchBar.text, !searchText.isEmpty {
                if searchRequest != nil {
                    searchRequest?.cancel()
                    searchRequest = nil
                }
              
                searchMarketData.removeAll()
                spinner.startAnimating()
                
                searchRequest = networkManager.getActiveProductsWithFilters(page: nil, completion: { [weak self] products in
                    guard let sSelf = self else { return }
                    sSelf.spinner.stopAnimating()
                    sSelf.marketData = products.filter({ $0.productName.lowercased().contains(find: searchText.lowercased())})
                    sSelf.tableView.reloadData()
                  
                    sSelf.title = "Барахолка"
                }) {  [weak self] error in
                    print(error)
                    self?.spinner.stopAnimating()
                }
            } else {
                page = 0
                searchRequest?.cancel()
                searchRequest = nil
                loadData()
            }
    }
}

extension MarketPage: UpdateProductFeed {
    func updateProductFeed(productID: Int) {
        if let index = marketData.firstIndex(where: { $0.postID == productID }) {
            marketData.remove(at: index)
            tableView.reloadData()
        }
    }
}

extension MarketPage: UpdateWithFiltersDelegate {
    func updateWithFilters() {
        page = 0
        loadData()
        print("[NETWORK] reload products with filters")
    }
}


extension MarketPage: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return VCFabric.getMarketPage()
    }
    
    static func canHandle(_ deeplink: Deeplink) -> Bool {
        guard let url = deeplink.url, url.path.contains("/products/") else { return false }
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
        
        networkManager.getProductByID(postID: id) { [weak self] product in
            self?.navigationController?.pushViewController(VCFabric.getProductPage(product: product), animated: true)
        } failure: { _ in
            PopupView.init(title: "", subtitle: "Объявление не найдено", image: UIImage(named: "cancel")).show()
        }
        
    }
}
