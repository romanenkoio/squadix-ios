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
    
    static func getPoints() -> (menu: [[ContentType]], headers: [String])  {
        let firstSection: [ContentType] = [.authorInfo, .images]
        let secondSection: [ContentType] = [.price, .region, .postAvalible]
        let thirdSection: [ContentType] = [.description]
        return ([firstSection, secondSection, thirdSection], ["", "", "Описание"])
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
    var product: MarketProduct!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(SimpleTextCell.self)
        tableView.registerCell(SlideShowCell.self)
        tableView.registerCell(AuthorCell.self)
        tableView.registerCell(PostSwitcherCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
    }
    
    func configureUI() {
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
        
        #if DEBUG
        if let date = formatter.date(from: product.upTime), date.canUpAction(), product.authorID == KeychainManager.profileID  {
            upButton.isHidden = false
        } else if KeychainManager.isAdmin  {
            upButton.isHidden = false
        } else {
            upButton.isHidden = true
        }
        #else
        upButton.isHidden = true
        print("Up button hide in prod!")
        #endif
        
        upButton.isHidden = !KeychainManager.isAdmin
        
       
    }
    
    @IBAction func contactAction(_ sender: Any) {
        
        spinner.startAnimating()
        service.getUserById(id: product.authorID) { (profile, error) in
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
                PopupView(title: "", subtitle: "Ошибка получения номера", image: UIImage(named: "cancel")).show()
                self.spinner.stopAnimating()
                return
            }
        }
    }
    
    @IBAction func upAction(_ sender: Any) {
        networkManager.upProduct(id: product.postID) {
            PopupView(title: "", subtitle: "Успешно поднято", image: UIImage(named: "confirm")).show()
        } failure: { error in
            PopupView(title: "", subtitle: "Что-то пошло не так", image: UIImage(named: "cancel")).show()
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Удалить объявление", style: .destructive) { [weak self] _ in
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



