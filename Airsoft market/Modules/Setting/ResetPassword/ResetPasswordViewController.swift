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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Смена пароля"
    }
    
    @IBAction func savePasswordAction(_ sender: Any) {
        spinner.startAnimating()
        
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

        
        networkManager.changePassword(currentPassword: oldPassword, newPassword: password) { [weak self] in
            self?.newPasswordField.text = ""
            self?.oldPasswordField.text = ""
            self?.secondNewPasswordField.text = ""
            PopupView(title: "", subtitle: "Пароль успешно изменён", image: UIImage(named: "confirm")).show()
        } failure: { error in
            PopupView(title: "", subtitle: error, image: UIImage(named: "cancel")).show()
        }

        
        spinner.stopAnimating()
    }
}
