//
//  SettingsPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/29/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit


enum SettingsMenu {
    case scrollUp
    case showUSDPrice
    case about
    case rules
    case promo
    case logout
    case useFaceId
    case debug
    case testQR
    case eraseFilterData
    case changePassword
    case privacy
    case userAgreement
    case chat
    case sendNotification
    case categories
    case quality
    case version
    case support
    case newVersionInfo
    case blackList
    
    static func getSettingsMenu(blockedCount: Int = 0) -> [[SettingsMenu]] {
        let settingsSection: [SettingsMenu] = [.showUSDPrice]
        let infoSection: [SettingsMenu] = [.privacy, .userAgreement, .rules]
        let actionSection: [SettingsMenu] = blockedCount == 0 ? [.changePassword, .logout] : [.blackList, .changePassword, .logout]
        let developerSection: [SettingsMenu] = [.debug]
        let systemSection: [SettingsMenu] = [.support, .version]
        
        #if DEBUG
        return [settingsSection, infoSection, actionSection, developerSection, systemSection]
        #else
        return KeychainManager.isAdmin ? [settingsSection, infoSection, actionSection, developerSection, systemSection] : [settingsSection, infoSection, actionSection, systemSection]
        #endif
    }
}


class SettingsPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var menu = SettingsMenu.getSettingsMenu()
    var blockedUsers: [Profile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(SettingsCell.self)
        tableView.registerCell(SettingsSwitchCell.self)
        tableView.registerCell(SimpleTextCell.self)
        tableView.setupDelegateData(self)
        title = "Настройки"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBlackList()
    }
    
    func loadBlackList() {
        networkManager.getBlackList { [weak self] blockedUsers in
            self?.blockedUsers = blockedUsers
            self?.menu = SettingsMenu.getSettingsMenu(blockedCount: blockedUsers.count)
            self?.tableView.reloadData()
        }
    }
}

extension SettingsPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
        let type = menu[indexPath.section][indexPath.row]
        
        switch type {
        case .blackList:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Заблокированные пользователи: \(blockedUsers.count)"
              
                settingCell.isUserInteractionEnabled = true
                settingCell.action = { [weak self] in
                    let vc = PeopleSearchPage.loadFromNib()
                    guard let users = self?.blockedUsers else { return }
                    vc.usersData = users
                    vc.isBlackList = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return settingCell
            }
        case .scrollUp:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsSwitchCell.self), for: indexPath)
            if let settingCell = cell as? SettingsSwitchCell {
                settingCell.settingsSwitchLabel.text = "Возврат в начало ленты по нажатию"
                return settingCell
            }
        case .showUSDPrice:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsSwitchCell.self), for: indexPath)
            if let settingCell = cell as? SettingsSwitchCell {
                settingCell.settingsSwitchLabel.text = "Отображать цену в USD по курсу"
                settingCell.settingsSwitch.isOn = UsersData.shared.isUSDCurrencyEnabled
                settingCell.action = {
                    UsersData.shared.isUSDCurrencyEnabled = !UsersData.shared.isUSDCurrencyEnabled
                }

                return settingCell
            }
        case .newVersionInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsSwitchCell.self), for: indexPath)
            if let settingCell = cell as? SettingsSwitchCell {
                settingCell.settingsSwitchLabel.text = "Оповещение об обновлениях"
                settingCell.settingsSwitch.isOn = UsersData.shared.informNevVersion
                settingCell.action = {
                    UsersData.shared.informNevVersion = !UsersData.shared.informNevVersion
                }

                return settingCell
            }
        case .about:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "О приложении"
            
                return settingCell
            }
        case .rules:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Правила размещения объявлений"
              
                settingCell.isUserInteractionEnabled = true
                settingCell.action = { [weak self] in
                    let vc = TextPage.loadFromNib()
                    vc.type = .rules
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return settingCell
            }
        case .promo:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Сотрудничество"
              
                return settingCell
            }
        case .logout:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Выйти из аккаунта"
                
                settingCell.action = {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    if UIDevice.current.type == .simulator {
                        appDelegate.logout()
                    } else {
                        self.spinner.startAnimating()
                        self.networkManager.unsubscribeNotification {
                            print("[NOTIFICATIONS] Unsubscribe")
                            self.spinner.stopAnimating()
                            appDelegate.logout()
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        } failure: { error in
                            self.spinner.stopAnimating()
                            appDelegate.logout()
//                            self.showPopup(isError: true, title: "Что-то пошло не так")
                        }
                    }
                }
                return settingCell
            }
        case .useFaceId:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsSwitchCell.self), for: indexPath)
            
            if let settingCell = cell as? SettingsSwitchCell {
                settingCell.settingsSwitch.isOn = UsersData.shared.useBiometric
                settingCell.settingsSwitchLabel.text = "Использовать \(UIDevice.current.phoneModel().biometricString) для входа"
                settingCell.action = {
                    UsersData.shared.useBiometric = !UsersData.shared.useBiometric
                }
                return settingCell
            }
        case .debug:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Debug info"
                settingCell.action = {
                    self.navigationController?.present(DebugPage.loadFromNib(), animated: true)
                }
                return settingCell
            }
        case .eraseFilterData:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Erase filters data"
                settingCell.action = {
                    RealmService.eraseFilters()
                }
                return settingCell
            }
        case .testQR:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Debug QR"
                settingCell.action = {
                    
                    let alert = UIAlertController(title: "Debug", message: "Enter a debug text", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.text = ""
                    }
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        guard let textFieldText = alert?.textFields![0].text, !textFieldText.isEmpty else { return }
                        
                        guard let qrToShare = QRGenerator.shared.generate(with: textFieldText) else { return }
                        
                        let objectsToShare = [qrToShare] as [Any]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                        
                        guard let top = self.navigationController?.topViewController else { return }
                        top.present(activityVC, animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return settingCell
            }
            
        case .changePassword:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Сменить пароль"
                settingCell.action = { [weak self] in
                    self?.navigationController?.pushViewController(ResetPasswordViewController.loadFromNib(), animated: true)
                }
                return settingCell
            }
        case .chat:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Chat"
                settingCell.action = {
                    self.navigationController?.pushViewController(ConservationPage.loadFromNib(), animated: true)
                }
                return settingCell
            }
        case .quality:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Экономия трафика"
                settingCell.action = {
                    
                    let menu: [Common.ImageQuality] = [.high, .normal, .medium, .low]
                    let alert = UIAlertController(title: "", message: "Выберите качество отправляемых изображений", preferredStyle: .actionSheet)
                    
                    for item in menu {
                        
                        let action = UIAlertAction(title: item.settingName, style: UIAlertAction.Style.default, handler: { _ in
                            UsersData.shared.quality = item.rawValue
                        })
                        
                        if UsersData.shared.quality == item.rawValue {
                            action.setValue(UIImage(named: "ok")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), forKey: "image")
                        }
                        alert.addAction(action)
                        
                    }
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return settingCell
            }
        case .userAgreement:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Пользовательское соглашение"
                settingCell.action = { [weak self] in
                    let vc = TextPage.loadFromNib()
                    vc.type = .license
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return settingCell
            }
        case .privacy:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Политика конфиденциальности"
                settingCell.action = { [weak self] in
                    let vc = TextPage.loadFromNib()
                    vc.type = .confidence
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                return settingCell
            }
        case .version:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsSwitchCell.self), for: indexPath)
            if let settingCell = cell as? SettingsSwitchCell {
                guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return cell }
                settingCell.settingsSwitchLabel.text = "Версия: \(version)_\(build)"
                settingCell.settingsSwitch.isHidden = true
                settingCell.isUserInteractionEnabled = false
                return settingCell
            }
        case .sendNotification:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Нотификация всем пользователям"
                settingCell.action = {
                    let alert = UIAlertController(title: "", message: "Заполните данные", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.placeholder = "Текст сообщения:"
                    }
                    
                    alert.addTextField { (textField) in
                        textField.placeholder = "Ссылка на пост"
                    }
                    
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak alert] (_) in
                        guard let message = alert?.textFields![0].text, !message.isEmpty, let url = alert?.textFields![1].text else { return }
       
                        UtilitesManager.shared.sendNotifications(message: message, url: url) {
                            self.showPopup(title: "Отправлено")
                        } failure: { error in
                            self.showPopup(isError: true, title: "Ошибка отправки")
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return settingCell
            }
        case .categories:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Управление категориями"
                settingCell.action = {
                    self.navigationController?.pushViewController(CategoriesPage.loadFromNib(), animated: true)
                }
                return settingCell
            }
        case .support:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Поддержка"
                settingCell.action = {
                    if let url = URL(string: "vk://vk.com/squadix") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                return settingCell
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
