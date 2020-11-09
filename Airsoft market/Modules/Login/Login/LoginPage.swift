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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Вход в аккаунт"
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func registrationAction(_ sender: Any) {
        navigationController?.pushViewController(VCFabric.getRegistrationPage(), animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if checkLoginValidate() {
            indicator.startAnimating()
            let credentials = ProfileRequest(email: emailTextField.text, password: passwordInpudField.text)
            let networkManager = NetworkManager()

            networkManager.login(loginCredentials: credentials, completion: { token in
                self.indicator.stopAnimating()
                KeychainManager.store(value: token.getFullToken(), for: .accessToken)
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                appDelegate.showMainMenu()
            }, failure: { error in
                self.indicator.stopAnimating()
                print(error)
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

