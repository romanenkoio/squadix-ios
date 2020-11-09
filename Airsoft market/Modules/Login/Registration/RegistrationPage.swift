//
//  RegistrationPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/22/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

struct ProfileRequest {
    var password: String?
    var email: String?
    var displayName: String?
    var phone: String?
    
    init(password: String?, email: String?, userName: String?, phone: String?) {
        self.password = password
        self.email = email
        self.displayName = userName
        self.phone = phone
    }
    
    init(email: String?, password: String?) {
        self.password = password
        self.email = email
        self.displayName = nil
        self.phone = nil
    }
    
    init() {
    }
    
}

class RegistrationPage: UIViewController {
    @IBOutlet weak var passwordField: StrikeInputField!
    @IBOutlet weak var doublePasswordField: StrikeInputField!
    @IBOutlet weak var emailField: StrikeInputField!
    @IBOutlet weak var userNameField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var firstPasswordErrorLabel: UILabel!
    @IBOutlet weak var secondPasswordErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var phoneField: StrikeInputField!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    
    lazy var networkManager = NetworkManager()
    var credentials = ProfileRequest()
    var checked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Регистрация"
    }
    
    @IBAction func registrationAction(_ sender: Any) {
        validateRegistration()
    }
    
    @IBAction func checkTermsOfUse(_ sender: Any) {
        checked = !checked
        checkBoxButton.setImage(checked ? UIImage(named: "checkBox_fill") : UIImage(named: "checkBox"), for: .normal)
    }
    
    @IBAction func phoneInfoAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Номер телефона в формате +375291234567. Используется для связи покупателя с продавцом. ", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { _ in
        
        })
        
        present(alert, animated: true)
    }
    
    
    func validateRegistration()  {
        var  isValid = true
        
        if let email = emailField.text {
            if email.count < 3 || email.count > 30 {
                emailErrorLabel.text = "Email должен быть до 30 символов"
                emailErrorLabel.isHidden = false
                isValid = false
            } else if !isValidEmail(email) {
                emailErrorLabel.text = "Проверьте правильность email"
                emailErrorLabel.isHidden = false
                isValid = false
            } else {
                emailErrorLabel.isHidden = true
                credentials.email = email
            }
        }
        
        if let password = passwordField.text, let secondPassword = doublePasswordField.text, password.count >= 8 , secondPassword.count >= 8 {
            if password != secondPassword {
                isValid = false
                firstPasswordErrorLabel.isHidden = false
                secondPasswordErrorLabel.isHidden = false
                firstPasswordErrorLabel.text = "Пароли не совпадают"
                secondPasswordErrorLabel.text = "Пароли не совпадают"
            } else if !isValidPasswod(password) {
                isValid = false
                firstPasswordErrorLabel.text = "Пароль должен сожержать буквы и цифры, от 8 символов"
                secondPasswordErrorLabel.text = "Пароль должен сожержать буквы и цифры, от 8 символов"
                firstPasswordErrorLabel.isHidden = false
                secondPasswordErrorLabel.isHidden = false
            } else {
                firstPasswordErrorLabel.isHidden = true
                secondPasswordErrorLabel.isHidden = true
                credentials.password = password
            }
        } else {
            firstPasswordErrorLabel.text = "Пароль должен сожержать буквы и цифры, от 8 символов"
            secondPasswordErrorLabel.text = "Пароль должен сожержать буквы и цифры, от 8 символов"
            firstPasswordErrorLabel.isHidden = false
            secondPasswordErrorLabel.isHidden = false
        }
        
        if let name = userNameField.text {
            if name.count < 3 {
                isValid = false
                nameErrorLabel.isHidden = false
                nameErrorLabel.text = "Имя должно быть от 3 до 30 символов"
            } else {
                nameErrorLabel.isHidden = true
                credentials.displayName = name
            }
        }
        
        
        if let phone = phoneField.text, isValidPhone(phone) {
            credentials.phone = phone
            phoneErrorLabel.isHidden = true
        } else {
            isValid = false
            phoneErrorLabel.text = "Телефон должен быть вида \"+375251234567\""
            phoneErrorLabel.isHidden = false
        }
       
        if isValid && checked {
            login()
        }
    }
    
    func login() {
        spinner.startAnimating()
        networkManager.register(loginCredentials: credentials, completion: { [weak self] token in
            KeychainManager.store(value: token.getFullToken(), for: .accessToken)
            self?.spinner.stopAnimating()
            self?.navigationController?.pushViewController(VCFabric.getPicturePage(), animated: true)
        }) { [weak self] error in
            self?.spinner.stopAnimating()
            self?.parseError(error: error)
        }
    }
    
    func isValidPasswod(_ password: String) -> Bool {
        let passwordRegEx = "[\\S]{8,}"
        
        let passPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passPred.evaluate(with: password)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
          let passwordRegEx = "^(\\+375)(29|25|44|33)(\\d{3})(\\d{2})(\\d{2})$"
          
          let passPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
          return passPred.evaluate(with: phone)
      }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-z0-9_.+-]+@[A-z0-9-]+(\\.[A-z0-9-]{2,})+$"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func parseError(error: NetworkError) {
        if error.message.contains(find: "email") && error.message.contains(find: "already exists") {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "Пользователь с таким адресом уже существует"
        } else {
            emailErrorLabel.isHidden = true
        }
        print("Network error: \(error.message)")
    }
}


