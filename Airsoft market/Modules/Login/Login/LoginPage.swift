//
//  LoginPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/22/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class LoginPage: UIViewController {
    @IBOutlet weak var emailTextField: StrikeInputField!
    @IBOutlet weak var passwordInpudField: StrikeInputField!
    @IBOutlet weak var loginButton: OliveButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var visibilityButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Вход в аккаунт"
        let image = UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate)
        visibilityButton.setImage(image, for: .normal)
        visibilityButton.tintColor = .gray
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func showPassword(_ sender: Any) {
        passwordInpudField.isSecureTextEntry = !passwordInpudField.isSecureTextEntry
        visibilityButton.setImage(passwordInpudField.isSecureTextEntry ? UIImage(named: "visibility")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "visibility_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @IBAction func registrationAction(_ sender: Any) {
        navigationController?.pushViewController(RegistrationPage.loadFromNib(), animated: true)
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        navigationController?.pushViewController(StartRestorePage.loadFromNib(), animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if checkLoginValidate() {
            indicator.startAnimating()
            let credentials = ProfileRequest(email: emailTextField.text, password: passwordInpudField.text)
            let networkManager = NetworkManager()
            loginButton.isEnabled = false
            
            networkManager.login(loginCredentials: credentials, completion: { token in
                self.indicator.stopAnimating()
                KeychainManager.store(value: token.getFullToken(), for: .accessToken)
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                self.loginButton.isEnabled = true
                appDelegate.showMainMenu()
            }, failure: { error in
                self.indicator.stopAnimating()
                print(error)
                self.loginButton.isEnabled = true
                PopupView.init(title: "", subtitle: LoginErrors.badCredentials.rawValue, image: UIImage(named: "cancel")).show()
            })
        } else {
            PopupView.init(title: "", subtitle: LoginErrors.invalide.rawValue, image: UIImage(named: "cancel")).show()
        }
    }
    
    func checkLoginValidate() -> Bool {
        return emailTextField.validateTextField(lenghtCondition: 6) && passwordInpudField.validateTextField(lenghtCondition: 6)
    }
}

extension LoginPage {
    private enum LoginErrors: String {
        case invalide = "Email и пароль не могут быть короче 6 символов."
        case badCredentials = "Неправильный email и/или пароль."
    }
}
