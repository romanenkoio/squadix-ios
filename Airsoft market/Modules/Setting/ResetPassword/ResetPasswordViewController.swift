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
    
    var isRestore: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Смена пароля"
        oldPasswordField.isHidden = isRestore
        
        navigationController?.setNavigationBarHidden(isRestore, animated: true)
        tabBarController?.tabBar.isHidden = isRestore
    }
    
    @IBAction func savePasswordAction(_ sender: Any) {
        spinner.startAnimating()
        if isRestore {
            
        } else {
            guard let oldPassword = oldPasswordField.text, !oldPassword.isEmpty, let password = newPasswordField.text, !password.isEmpty, let secondPasssword = secondNewPasswordField.text, !secondPasssword.isEmpty else {
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
            
            guard oldPassword != password else {
                PopupView(title: "", subtitle: "Пароли не могут совпадать", image: UIImage(named: "cancel")).show()
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
        guard let url = deeplink.url, url.path.contains("/restore/") else { return false }
        let postID = url.path.matches(for: "[0-9]+").first
        if let postID = postID, Int(postID) != nil {
            return true
        }
        return false
    }
    
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool {
        return false
    }
    
    func handle(_ deeplink: Deeplink) {
        isRestore = true
    }
    
    
}
