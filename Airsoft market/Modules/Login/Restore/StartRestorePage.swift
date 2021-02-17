//
//  StartRestorePage.swift
//  Squadix
//
//  Created by Illia Romanenko on 5.02.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class StartRestorePage: BaseViewController {
    @IBOutlet weak var emailTextField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Восстановление пароля"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func restoreAction(_ sender: Any) {
        spinner.startAnimating()
        guard let email = emailTextField.text, !email.isEmpty, Validator.shared.validate(string: email, pattern: Validator.Regexp.email.rawValue) else {
            showPopup(isError: true, title: "Проверьте правильность email")
            spinner.stopAnimating()
            return
        }
        networkManager.resetPassword(email: email) { [weak self] in
            self?.showAlert(maintText: "Успешно", title: "Проверьте вашу почту.")
            self?.spinner.stopAnimating()
        } failure: { error in
            self.showPopup(isError: true, title: "Ошибка. Попробуйте позже")
            self.spinner.stopAnimating()
        }

        
    }
}
