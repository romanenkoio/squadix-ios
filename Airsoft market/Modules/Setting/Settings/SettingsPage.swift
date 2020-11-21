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
    
    static func getSettingsMenu() -> [[SettingsMenu]] {
        let settingsSection: [SettingsMenu] = [.showUSDPrice]
        let infoSection: [SettingsMenu] = [.about, .rules, .promo]
        let actionSection: [SettingsMenu] = [ .debug, .changePassword, .logout]
         
        return [settingsSection, infoSection, actionSection]
    }
}


class SettingsPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let menu = SettingsMenu.getSettingsMenu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(SettingsCell.self)
        tableView.registerCell(SettingsSwitchCell.self)
        tableView.setupDelegateData(self)
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
        case .about:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "О приложении"
            
                return settingCell
            }
        case .rules:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath)
            if let settingCell = cell as? SettingsCell {
                settingCell.settingLabel.text = "Правила"
              
                settingCell.isUserInteractionEnabled = true
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
                    appDelegate.showLogin()
                    KeychainManager.clearAll()
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
                    self.navigationController?.present(VCFabric.getDebugPage(), animated: true)
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
                settingCell.action = {
                    let alert = UIAlertController(title: "", message: "Смена пароля", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.placeholder = "Старый пароль"
                    }
                    
                    alert.addTextField { (textField) in
                        textField.placeholder = "Новый пароль"
                    }
                    
                    alert.addTextField { (textFieldPass) in
                        textFieldPass.placeholder = "Новый пароль ещё раз"
                    }
                    
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "Сохранить пароль", style: .default, handler: { [weak alert, self] (_) in
                        guard let oldPassword = alert?.textFields![0].text, !oldPassword.isEmpty, let newPassword = alert?.textFields![1].text,  let newSecondPassword = alert?.textFields![2].text, !newPassword.isEmpty, !newSecondPassword.isEmpty else { return }
                        if newPassword != newSecondPassword {
                            self.showAlert(title: "Новые пароли не совпадают, повторите попытку.")
                        } else if !Validator.shared.validate(string: newPassword, pattern: Validator.Regexp.password.rawValue), !Validator.shared.validate(string: newSecondPassword, pattern: Validator.Regexp.password.rawValue) {
                            self.showAlert(title: "Новый пароль должен быть от 8 до 20 символов.")
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
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
