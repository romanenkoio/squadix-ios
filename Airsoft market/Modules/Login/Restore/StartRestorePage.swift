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
            PopupView.init(title: "", subtitle: "Проверьте правильность email", image: UIImage(named: "cancel")).show()
            spinner.stopAnimating()
            return
        }
        networkManager.resetPassword(email: email) {
            let alert = UIAlertController(title: "Успешно", message: "Проверьте вашу почту.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.spinner.stopAnimating()
        } failure: { error in
            PopupView(title: "Ошибка. Попробуйте позже", subtitle: nil, image: UIImage(named: "cancel")).show()
            self.spinner.stopAnimating()
        }

        
    }
}
