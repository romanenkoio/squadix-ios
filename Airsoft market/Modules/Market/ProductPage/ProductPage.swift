//
//  ProductPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow

typealias VoidBlock = () -> Void
typealias UserBlock = (Profile) -> Void

protocol UpdateProductFeed: class {
    func updateProductFeed(productID: Int)
}

enum ContentType {
    case images
    case authorInfo
    case price
    case region
    case description
    case postAvalible
    case reserve
    case category
    
    static func getPoints() -> (menu: [[ContentType]], headers: [String])  {
        let firstSection: [ContentType] = [.authorInfo, .images]
        let secondSection: [ContentType] = [.price, .region, .postAvalible, .category, .reserve]
        let thirdSection: [ContentType] = [.description]
        
        return ([firstSection, secondSection, thirdSection, ], ["", "", "Описание"])
    }
}

class ProductPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var upButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    weak var delegate: UpdateProductFeed?
    
    lazy var service = NetworkManager()
    var menu: [[ContentType]] = []
    var sectionDescription: [String] = []
    var comments: [Comment] = []
    var product: MarketProduct!
    let formatter = DateFormatter()
    var shouldScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(SimpleTextCell.self)
        tableView.registerCell(SlideShowCell.self)
        tableView.registerCell(AuthorCell.self)
        tableView.registerCell(PostSwitcherCell.self)
        Analytics.trackEvent("Product_screen")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
    }
    
    func configureUI() {
        guard product.authorName != nil else { return }
        title = product.productName
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        let menuInfo = ContentType.getPoints()
        menu = menuInfo.menu
        sectionDescription = menuInfo.headers
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: moreButton),
                                               UIBarButtonItem(customView: upButton),
                                               UIBarButtonItem(customView: contactButton)],
                                              animated: true)
        
        contactButton.isHidden = product.authorID == KeychainManager.profileID
     
        if product.isPreview {
            moreButton.isHidden = true
            upButton.isHidden = true
        } else {
            moreButton.isHidden = product.authorID != KeychainManager.profileID
        }
        
        if !product.isPreview, KeychainManager.isAdmin {
            moreButton.isHidden = false
        }
        
        if let date = formatter.date(from: product.createdAt), date.canUpAction(), product.authorID == KeychainManager.profileID  {
            upButton.isHidden = false
        } else if KeychainManager.isAdmin  {
            upButton.isHidden = false
        } else {
            upButton.isHidden = true
        }
        
   
        if let date = formatter.date(from: product.upTime), date.canUpAction(), product.authorID == KeychainManager.profileID  {
            upButton.isHidden = false
        } else {
            upButton.isHidden = true
        }
        
        upButton.isHidden = !KeychainManager.isAdmin
    }
    
    @IBAction func contactAction(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let phone = product.authorPhone {
            alert.addAction(UIAlertAction(title: "Позвонить", style: .default, handler: { _ in
                Analytics.trackEvent("Get_phone")
                let url = "tel://\(phone)"
                guard let contactUrl = URL.init(string: url) else { return }
                UIApplication.shared.open(contactUrl)
            }))
        }
        
        if let vk = product.authorVK {
            guard let url = URL(string: "vk://vk.com/\(vk)") else { return }
            alert.addAction(UIAlertAction(title: "VK", style: .default, handler: { _ in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }))
        }
        
        if let tg = product.authorTg {
            alert.addAction(UIAlertAction(title: "Telegram", style: .default, handler: { _ in
                let url = "tg://resolve?domain=\(tg)"
                guard let contactUrl = URL.init(string: url) else { return }
                UIApplication.shared.open(contactUrl)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func upAction(_ sender: Any) {
        networkManager.upProduct(id: product.postID) {
            self.showPopup(title: "Успешно поднято")
            Analytics.trackEvent("Up_product")
        } failure: { error in
            self.showPopup(isError: true, title: "Что-то пошло не так")
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if product.authorID == KeychainManager.profileID {
            alert.addAction(UIAlertAction(title: product.reserved ? "Снять с резерва" : "Поставить в резерв", style: .default) { [weak self] _ in
                guard let prod = self?.product else { return }
                self?.networkManager.editProduct(product: prod, completion: {
                    self?.product.reserved = !prod.reserved
                    self?.tableView.reloadData()
                    self?.showPopup(title: prod.reserved ? "Поставлено в резерв" : "Снято с резерва")
                }, failure: {
                    self?.showPopup(isError: true, title: "Ошибка, попробуйте позже.")
                })
            })
        }
        
        alert.addAction(UIAlertAction(title: "Удалить объявление", style: .destructive) { [weak self] _ in
            self?.showDestructiveAlert(handler: {
                self?.spinner.startAnimating()
             
                guard let product = self?.product else { return }
                self?.service.deleteProduct(id: product.postID, completion: {
                    self?.spinner.stopAnimating()
                    self?.delegate?.updateProductFeed(productID: product.postID)
                    self?.navigationController?.popViewController(animated: true)
                }) { error in
                    self?.spinner.stopAnimating()
                    print("Error: \(error)")
                }
            })
        })
        
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
        present(alert, animated: true)
    }
}

extension ProductPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0, indexPath.section == 0 {
            navigationController?.pushViewController(ProfilePage.loadFromNib(), animated: true)
        }
    }
}

extension ProductPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SlideShowCell.self), for: indexPath)
        
        let type = menu[indexPath.section][indexPath.row]
        
        switch type {
        case .images:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SlideShowCell.self), for: indexPath)
            if let imageCell = cell as? SlideShowCell {
                
                imageCell.imageSlideshow.setupView()
                if product.isPreview {
                    if let images = product.images {
                        imageCell.imageSlideshow.setupImagesWithImages(images)
                    }
                } else {
                    imageCell.imageSlideshow.setupImagesWithUrls(product.picturesUrl)
                }
                imageCell.action = {
                    imageCell.imageSlideshow.presentFullScreenController(from: self)
                }
                return imageCell
            }
        case .authorInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AuthorCell.self), for: indexPath)
            if let profileCell = cell as? AuthorCell {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                if product.isPreview {
                    profileCell.postDateLabel.text = product.createdAt
                } else {
                    if let date = formatter.date(from: product.createdAt) {
                        profileCell.postDateLabel.text = date.dateToHumanString()
                    }
                }
                profileCell.authorName.text = product.authorName

                
                if let imageUrl = product.authorAvatarURL {
                    profileCell.profileAvatarImage.loadImageWith(imageUrl)
                }
                
                profileCell.action = { [weak self] in
                    guard let id = self?.product.authorID else { return }
                    self?.navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
                }
                return profileCell
            }
        case .price:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let price = product.price {
                    if UsersData.shared.isUSDCurrencyEnabled {
                        let usdPrice = String(format: "%0.2f $",
                                              Double(price) / UsersData.shared.currency)
                        profileCell.simpleTextLabel.text = "Цена: \(price) руб / \(usdPrice)"
                    } else {
                        profileCell.simpleTextLabel.text = "Цена: \(price) руб"
                    }
                }
                return profileCell
            }
        case .reserve:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                profileCell.simpleTextLabel.text = product.reserved ? "Зарезервировано: да" : "Зарезервировано: нет"
                profileCell.backgroundColor = product.reserved ? .yellow : .white
                return profileCell
            }
        case .region:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let region = product.productRegion {
                    profileCell.simpleTextLabel.text = "Город: \(region)"
                } else {
                    profileCell.simpleTextLabel.text = "Город не указан"
                }
                return profileCell
            }
        case .category:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let category = product.productCategory {
                    profileCell.simpleTextLabel.text = "Категория: \(category)"
                }
                return profileCell
            }
        case .description:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimpleTextCell.self), for: indexPath)
            if let profileCell = cell as? SimpleTextCell {
                profileCell.isUserInteractionEnabled = false
                if let description = product.description {
                    profileCell.simpleTextLabel.text = "\(description)"
                }
                return profileCell
            }
        case .postAvalible:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostSwitcherCell.self), for: indexPath)
            if let postCell = cell as? PostSwitcherCell {
                postCell.isUserInteractionEnabled = false
                postCell.setup(product.postAvalible)
                return postCell
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return  CustomTableHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 0
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionDescription[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu[section].count
    }
}

extension ProductPage: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return VCFabric.getProductPage(product: MarketProduct())
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
            if product.status == .some(.active) {
                self?.product = product
                self?.configureUI()
                self?.tableView.reloadData()
//                self?.navigationController?.pushViewController(VCFabric.getProductPage(product: product), animated: true)
            } else {
                self?.navigationController?.popViewController(animated: true)
                self?.showPopup(isError: true, title: "Объявление недоступно")
            }
        } failure: { _ in
            self.showPopup(isError: true, title: "Объявление не найдено")
        }
        
    }
}
