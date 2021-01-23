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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override var shouldBackSwipe: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    @IBAction func savePasswordAction(_ sender: Any) {
        spinner.startAnimating()
        guard let password = newPasswordField.text, !password.isEmpty, let secondPasssword = secondNewPasswordField.text, !secondPasssword.isEmpty, password == secondPasssword else {
            PopupView(title: "", subtitle: "Пароли должны совпадать", image: UIImage(named: "cancel")).show()
            return
        }
        guard Validator.shared.validate(string: password, pattern: Validator.Regexp.password.rawValue), Validator.shared.validate(string: secondPasssword, pattern: Validator.Regexp.password.rawValue) else {
            PopupView(title: "", subtitle: "Пароли должны быть от 8 символов", image: UIImage(named: "cancel")).show()
            return
        }
//        стартануть запрос
        spinner.stopAnimating()
    }
}

extension ResetPasswordViewController: DeeplinkRoutable {
    static func initControllerFromStoryboard() -> DeeplinkRoutable? {
        return ResetPasswordViewController.loadFromNib()
    }
    
    static func canHandle(_ deeplink: Deeplink) -> Bool {
        return false
    }
    
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool {
        return false
    }
    
    func handle(_ deeplink: Deeplink) {
        
    }
    
    
}
