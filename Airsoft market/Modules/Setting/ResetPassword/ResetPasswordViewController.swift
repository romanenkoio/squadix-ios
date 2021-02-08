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
    
    var restoreToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Смена пароля"
        oldPasswordField.isHidden = restoreToken != nil
        
        navigationController?.setNavigationBarHidden(restoreToken != nil, animated: true)
        tabBarController?.tabBar.isHidden = restoreToken != nil
    }
    
    @IBAction func savePasswordAction(_ sender: Any) {
        spinner.startAnimating()
        
        guard let password = newPasswordField.text, !password.isEmpty, let secondPasssword = secondNewPasswordField.text, !secondPasssword.isEmpty else {
            PopupView(title: "", subtitle: "Поля не могут быть пустыми", image: UIImage(named: "cancel")).show()
            spinner.stopAnimating()
            return
        }
        
        guard  password == secondPasssword else {
            PopupView(title: "", subtitle: "Пароли должны совпадать", image: UIImage(named: "cancel")).show()
            spinner.stopAnimating()
            return
        }
        
        guard Validator.shared.validate(string: password, pattern: Validator.Regexp.password.rawValue), Validator.shared.validate(string: secondPasssword, pattern: Validator.Regexp.password.rawValue) else {
            PopupView(title: "", subtitle: "Пароли должны быть от 8 символов", image: UIImage(named: "cancel")).show()
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
                PopupView(title: "", subtitle: "Что-то пошло не так. Попробуйте позже", image: UIImage(named: "cancel")).show()
            }

        } else {
            guard let oldPassword = oldPasswordField.text, !oldPassword.isEmpty, oldPassword != password else {
                PopupView(title: "", subtitle: "Пароли не могут совпадать или быть пустыми", image: UIImage(named: "cancel")).show()
                spinner.stopAnimating()
                return
            }
            
            networkManager.changePassword(currentPassword: oldPassword, newPassword: password) { [weak self] in
                self?.newPasswordField.text = ""
                self?.oldPasswordField.text = ""
                self?.secondNewPasswordField.text = ""
                self?.spinner.stopAnimating()
                PopupView(title: "", subtitle: "Пароль успешно изменён", image: UIImage(named: "confirm")).show()
            } failure: { [weak self] error in
                PopupView(title: "", subtitle: error, image: UIImage(named: "cancel")).show()
                self?.spinner.stopAnimating()
            }
        }
      
    }
}

extension ResetPasswordViewController: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        ResetPasswordViewController.loadFromNib()
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
