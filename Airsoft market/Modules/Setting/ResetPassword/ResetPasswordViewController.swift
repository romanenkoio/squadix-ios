//
//  ResetPasswordViewController.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BaseViewController {
    @IBOutlet weak var newPasswordField: StrikeInputField!
    @IBOutlet weak var secondNewPasswordField: StrikeInputField!
    @IBOutlet weak var oldPasswordField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var newVisibilityButton: UIButton!
    @IBOutlet weak var confirmVisibilityButton: UIButton!
    
    
    var restoreToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = restoreToken == nil ? "Смена пароля" : "Восстановление пароля"
        oldPasswordField.isHidden = restoreToken != nil
        visibilityButton.isHidden = restoreToken != nil
        let image = UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate)
        visibilityButton.setImage(image, for: .normal)
        newVisibilityButton.setImage(image, for: .normal)
        confirmVisibilityButton.setImage(image, for: .normal)
        
        navigationController?.setNavigationBarHidden(restoreToken != nil, animated: true)
        tabBarController?.tabBar.isHidden = restoreToken != nil
    }
    
    @IBAction func changeVisibility(_ sender: Any) {
        newPasswordField.isSecureTextEntry = !newPasswordField.isSecureTextEntry
        oldPasswordField.isSecureTextEntry = !oldPasswordField.isSecureTextEntry
        secondNewPasswordField.isSecureTextEntry = !secondNewPasswordField.isSecureTextEntry
        
        confirmVisibilityButton.setImage(newPasswordField.isSecureTextEntry ? UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "visibility_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
        visibilityButton.setImage(newPasswordField.isSecureTextEntry ? UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "visibility_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
        newVisibilityButton.setImage(newPasswordField.isSecureTextEntry ? UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "visibility_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    
    @IBAction func savePasswordAction(_ sender: Any) {
        spinner.startAnimating()
        
        guard let password = newPasswordField.text, !password.isEmpty, let secondPasssword = secondNewPasswordField.text, !secondPasssword.isEmpty else {
            self.showPopup(isError: true, title: "Поля не могут быть пустыми")
            spinner.stopAnimating()
            return
        }
        
        guard  password == secondPasssword else {
            self.showPopup(isError: true, title: "Пароли должны совпадать")
            spinner.stopAnimating()
            return
        }
        
        guard Validator.shared.validate(string: password, pattern: Validator.Regexp.password.rawValue), Validator.shared.validate(string: secondPasssword, pattern: Validator.Regexp.password.rawValue) else {
            self.showPopup(isError: true, title: "Пароли должны быть от 8 символов")
            spinner.stopAnimating()
            return
        }
        
        if restoreToken != nil {
            networkManager.resetPasswordConfirmation(newPassword: password, token: restoreToken ?? "") { [weak self] in
                self?.spinner.stopAnimating()
                
                let alert = UIAlertController(title: "", message: "Пароль успешно изменен", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { _ in
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    appDelegate.showLogin()
                    KeychainManager.clearAll()
                }))
                self?.present(alert, animated: true, completion: nil)
            } failure: {  [weak self] error in
                self?.spinner.stopAnimating()
                self?.showPopup(isError: true, title: "Что-то пошло не так. Попробуйте позже")
            }

        } else {
            guard let oldPassword = oldPasswordField.text, !oldPassword.isEmpty, oldPassword != password else {
                self.showPopup(isError: true, title: "Пароли не могут совпадать или быть пустыми")
                spinner.stopAnimating()
                return
            }
            
            networkManager.changePassword(currentPassword: oldPassword, newPassword: password) { [weak self] in
                self?.newPasswordField.text = ""
                self?.oldPasswordField.text = ""
                self?.secondNewPasswordField.text = ""
                self?.spinner.stopAnimating()
                self?.showPopup(title: "Пароль успешно изменён")
            } failure: { [weak self] error in
                self?.showPopup(isError: true, title: error)
                self?.spinner.stopAnimating()
            }
        }
      
    }
}

extension ResetPasswordViewController: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return ResetPasswordViewController.loadFromNib()
    }
    
    static func canHandle(_ deeplink: Deeplink) -> Bool {
        guard let url = deeplink.url, url.path.contains("/reset/") else { return false }
        return true
    }
    
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool {
        return false
    }
    
    func handle(_ deeplink: Deeplink) {
        guard let url = deeplink.url else {  return }
        restoreToken = url.lastPathComponent
    }
}
