//
//  ProfilePage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/25/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import Photos

enum ProfileMenuPoints {
     case profileInfo
     case description
     case profileStack
     
     static func getMenuForUser() -> [ProfileMenuPoints]{
          return [.profileInfo, description, .profileStack]
     }
}

class ProfilePage: BaseViewController {
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var spinner: UIActivityIndicatorView!

     var testImage = UIImage(named: "placeholder")
     var imagePicker = UIImagePickerController()
     var refreshControl = UIRefreshControl()
     var menuPoints: [ProfileMenuPoints] = ProfileMenuPoints.getMenuForUser()
     let actionButton = JJFloatingActionButton()
     
     var currentProfile: Profile? {
          didSet {
               tableView.reloadData()
          }
     }
     var userPosts: [Post] = [] {
          didSet {
               tableView.reloadData()
          }
     }
     var userProducts: [MarketProduct] = [] {
          didSet {
               tableView.reloadData()
          }
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          tableView.setupDelegateData(self)
          tableView.registerCell(ProfileCell.self)
          tableView.registerCell(ActionCell.self)
          tableView.registerCell(MyProfileCell.self)
          tableView.registerCell(HorisontalStackCell.self)
          tableView.registerCell(DescriptionPointCell.self)
          refreshControl.attributedTitle = NSAttributedString(string: "Обновление")
          refreshControl.addTarget(self, action: #selector(loadProfile), for: .valueChanged)
          tableView.addSubview(refreshControl)
          title = "Профиль"
          configureFloatingMenu()
          actionButton.display(inViewController: self)
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(true)
          if profileID != nil {
               tableView.isHidden = true
          }
          loadProfile(animated: profileID != nil)
     }
     
     func configureFloatingMenu() {
          actionButton.items = []
          actionButton.buttonColor = .mainStrikeColor
          actionButton.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
          actionButton.buttonImage = UIImage(named: "menu")
          actionButton.itemAnimationConfiguration = .popUp(withInterItemSpacing: 20, firstItemSpacing: 20)
          
          actionButton.addItem(title: "Настройки", image: UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)) { [weak self] item in
               self?.navigationController?.pushViewController(SettingsPage.loadFromNib(), animated: true)
          }
          
          actionButton.addItem(title: "Редактировать профиль", image: UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)) { [weak self] item in
               self?.navigationController?.pushViewController(VCFabric.getUserEditPage(isEdit: true, profile: self?.currentProfile), animated: true)
          }
          
          if KeychainManager.isAdmin {
               actionButton.addItem(title: "Создать категорию", image: UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)) { [weak self] item in
                    let alert = UIAlertController(title: "", message: "Смена пароля", preferredStyle: .alert)
                     
                    alert.addTextField { (textField) in
                         textField.placeholder = "Новая категория"
                    }
                    
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "Сохранить категорию", style: .default, handler: { [weak alert, self] (_) in
                         guard let categoryName = alert?.textFields![0].text, !categoryName.isEmpty else { return }
                         self?.networkManager.createCategory(with: categoryName, completion: { _ in
                              PopupView(title: "", subtitle: "Категория добавлена", image: UIImage(named: "confirm")).show()
                         })
                    }))
                    
                    self?.present(alert, animated: true, completion: nil)
               }
          }
          
          if KeychainManager.isOrganizer || KeychainManager.isAdmin {
               actionButton.addItem(title: "Сохранённые места", image: UIImage(named: "bookmarks")) { [weak self] item in
                    self?.navigationController?.pushViewController(VCFabric.getBookmarkPage(), animated: true)
               }
          }
          
          actionButton.configureDefaultItem { item in
               item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
               item.titleLabel.textColor = .white
               item.buttonColor = .white
               item.buttonImageColor = .black
          }
     }
     
     func didSelectAvatarChange() {
          let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
          imagePicker.delegate = self
          imagePicker.allowsEditing = true
          
          alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
               let status = PHPhotoLibrary.authorizationStatus()
               
               PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                         if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                              DispatchQueue.main.async {
                                   self?.imagePicker.sourceType = .savedPhotosAlbum
                                   self?.present(self!.imagePicker, animated: true, completion: nil)
                              }
                         }
                    } else if (status == PHAuthorizationStatus.denied) {
                         DispatchQueue.main.async {
                              self?.showPermissionAlert(for: .galery)
                         }
                    }
               })
          })
          
          alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self]  _ in
               AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                    if  accessGranted {
                         if UIImagePickerController.isSourceTypeAvailable(.camera) {
                              DispatchQueue.main.async {
                                   self?.imagePicker.sourceType = .camera
                                   self?.present(self!.imagePicker, animated: true, completion: nil)
                              }
                         }
                    } else {
                         DispatchQueue.main.async {
                              self?.showPermissionAlert(for: .camera)
                         }
                    }
               })
          })
          
          if (currentProfile?.profilePictureUrl) != nil {
               alert.addAction(UIAlertAction(title: "Удалить фото", style: .destructive) { [weak self]  _ in
                    self?.showDestructiveAlert(handler: {
                         self?.spinner.startAnimating()
                         self?.networkManager.deleteAvater {
                              self?.loadProfile()
                              self?.showPopup(isError: false, title: "Аватар удалён")
                              self?.spinner.stopAnimating()
                         } failure: { errror in
                              self?.spinner.stopAnimating()
                              self?.showPopup(isError: true, title: "Ошибка. Попробуйте позже")
                         }
                    })
               })
          }
          
          alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
          
          present(alert, animated: true)
     }
     
}

extension ProfilePage: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
     }
}

extension ProfilePage: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return menuPoints.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyProfileCell.self), for: indexPath)
          let type: ProfileMenuPoints = menuPoints[indexPath.row]
          
          switch type {
          case .profileInfo:
               cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyProfileCell.self), for: indexPath)
               if let myProfileCell = cell as? MyProfileCell {
                    myProfileCell.avatarSlider.setupView()
                    myProfileCell.isUserInteractionEnabled = true
                    guard let profile = currentProfile else { return cell }
                    
                    if let picture = profile.profilePictureUrl {
                         myProfileCell.avatarSlider.setupImagesWithUrls([picture])
                    } else if let image = UIImage(named: "avatar_placeholder") {
                         myProfileCell.avatarSlider.setupImagesWithImages([image])
                    }
                    
                    if let username = profile.profileName {
                         myProfileCell.userNameLabel.text = username
                    }
                    var reg = ""
                    
                    if let region = profile.country {
                         reg = region
                    }
                    
                    if let city = profile.city {
                         reg += ", \(city)"
                    }
                    
                    myProfileCell.regionLabel.text = reg
                    myProfileCell.avatarButton.isHidden = profileID != nil
                    myProfileCell.adminBadgeLabel.isHidden = !profile.roles.contains(.admin)
                    myProfileCell.adminBadgeLabel.text = profile.roles.contains(.admin) ? Common.Roles.admin.displayRoleName : ""
                    
                    myProfileCell.avatarAction = { [weak self] in
                         self?.didSelectAvatarChange()
                    }
                    myProfileCell.showAvatarAction = { [weak self] in
                         if let sSelf = self {
                              myProfileCell.avatarSlider.presentFullScreenController(from: sSelf)
                         }
                    }
                    myProfileCell.selectionStyle = .none
                    return myProfileCell
               }
          case .description:
               cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DescriptionPointCell.self), for: indexPath)
               if let profileCell = cell as? DescriptionPointCell {
                    profileCell.descriptionLabel.text = currentProfile?.profileDescription
                    profileCell.descriptionLabel.enabledTypes = [.url]
                    profileCell.descriptionLabel.customize { label in
                         label.handleURLTap { url in
                              if Deeplink.DeeplinkType.checkLinkType(url: url) != .unknow {
                                   Deeplink.Handler.shared.handle(deeplink: Deeplink(url: url))
                              } else {
                                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                              }
                            
                         }
                    }
                    profileCell.isUserInteractionEnabled = true
                    profileCell.selectionStyle = .none
                    return profileCell
               }
          case .profileStack:
               cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorisontalStackCell.self), for: indexPath)
               if let profileCell = cell as? HorisontalStackCell {
                    
                    profileCell.postCountLabel.text = "\(userPosts.count)"
                    profileCell.selectionStyle = .none
                    profileCell.action = {
                         let id = self.profileID == nil ? KeychainManager.profileID : self.profileID
                         guard self.userPosts.count != 0 else { return }
                         self.navigationController?.pushViewController(VCFabric.getNewsPage(type: .userFeed, for: id), animated: true)
                    }
                    
                    profileCell.salesCountLabel.text = "\(userProducts.count)"
                    profileCell.selectionStyle = .none
                    profileCell.productAction = {
                         guard self.userProducts.count != 0 else { return }
                         let id = self.profileID == nil ? KeychainManager.profileID : self.profileID
                         self.navigationController?.pushViewController(VCFabric.getMarketPage(for: id), animated: true)
                    }
                    
                    return profileCell
               }
          }
          return cell
     }
}

extension ProfilePage: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
               testImage = img
               spinner.startAnimating()
               dismiss(animated: true, completion: nil)
          }
     
          guard let image = testImage else { return }
          let manager = NetworkManager()
          manager.updloadAvatar(image: image, completion: {
               self.loadProfile(animated: true)
               self.spinner.startAnimating()
          }) { error in
               self.spinner.startAnimating()
               PopupView(title: "", subtitle: "Не удалось", image: UIImage(named: "cancel")).show()
               print(error ?? "Could'nt upload picture")
          }
     }
}

//MARK: network service

extension ProfilePage {
     @objc func loadProfile(animated: Bool = false) {
          if animated {
               spinner.startAnimating()
          }
          if profileID == nil {
               let networkManager = NetworkManager()
               networkManager.getCurrentUser { [weak self] (profile, error, _) in
                    guard let myProfile = profile else {
                         self?.refreshControl.endRefreshing()
                         return
                    }
                    self?.currentProfile = myProfile
                    self?.actionButton.alpha = KeychainManager.profileID == self?.currentProfile?.id ? 1 : 0
                    self?.refreshControl.endRefreshing()
                    self?.tableView.isHidden = false
                    self?.spinner.stopAnimating()
               }
          } else {
               let networkManager = NetworkManager()
               guard let id = profileID else { return }
               networkManager.getUserById(id: id) { [weak self]  (profile, error) in
                    guard let myProfile = profile else {
                         self?.refreshControl.endRefreshing()
                         return
                    }
                    self?.currentProfile = myProfile
                    self?.actionButton.alpha = KeychainManager.profileID == self?.currentProfile?.id ? 1 : 0
                    self?.refreshControl.endRefreshing()
                    self?.tableView.isHidden = false
                    self?.spinner.stopAnimating()
               }
               
          }
          loadPostInfo()
          loadProductInfo()
     }
     
     func loadPostInfo() {
          let networkManager = NetworkManager()
          userPosts = []
          guard let userID = profileID == nil ? KeychainManager.profileID : profileID else { return }
          networkManager.getPostsByUser(id: userID, completion: { [weak self] posts in
               self?.userPosts = posts.content
               self?.spinner.stopAnimating()
          }) { [weak self] error in
               self?.spinner.stopAnimating()
               print(error)
          }
     }
     
     func loadProductInfo() {
          let networkManager = NetworkManager()
          userPosts = []
          guard let userID = profileID == nil ? KeychainManager.profileID : profileID else { return }
          networkManager.getProductsByUser(id: userID, completion: { [weak self] posts in
               self?.userProducts = posts
               self?.spinner.stopAnimating()
          }) { [weak self] error in
               self?.spinner.stopAnimating()
               print(error)
          }
     }
}
