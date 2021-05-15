//
//  EditPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/4/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import GrowingTextView

class EditPage: BaseViewController {
    @IBOutlet weak var countryTextField: StrikeInputField!
    @IBOutlet weak var cityTextField: StrikeInputField!
    @IBOutlet weak var birthdayTextField: StrikeInputField!
    @IBOutlet weak var descriptionTextView: GrowingTextView!
    @IBOutlet weak var mainSaveButton: OliveButton!
    @IBOutlet weak var saveButton: OliveButton!
    @IBOutlet weak var skipButton: WhiteButton!
    @IBOutlet weak var userNameTextField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var phoneTextField: StrikeInputField!
    @IBOutlet weak var teamTextField: StrikeInputField!
    @IBOutlet weak var tgField: StrikeInputField!
    @IBOutlet weak var vkField: StrikeInputField!
    
    var selectedDate: Date?
    var profile: Profile?
    var isEdit: Bool = false
    var userPostCount = 0
    let manager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Детали"
        
        mainSaveButton.isHidden = !isEdit
        saveButton.isHidden = isEdit
        skipButton.isHidden = isEdit

        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        
        birthdayTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(selectDateAction(picker:)), for: .valueChanged)
     
        manager.getCurrentUser { (profile, rrror, _) in
            self.profile = profile
            self.preloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.startAnimating()
        guard let userID = KeychainManager.profileID else { return }
        manager.getProductsByUser(id: userID, completion: { [weak self] posts in
            self?.userPostCount = posts.count
             self?.spinner.stopAnimating()
        }) { [weak self] error in
             self?.spinner.stopAnimating()
             print(error)
        }
    }
    
    @IBAction func startSelectCity(_ sender: Any) {
        let vc = SelectCityPage.loadFromNib()
        vc.selectAction = { [weak self] selectedCity in
            self?.cityTextField.text = selectedCity.city
            self?.cityTextField.resignFirstResponder()
            self?.navigationController?.popViewController(animated: true)
        }
        pushController(vc)
    }
    
    func preloadData() {
        countryTextField.text = "Беларусь"
        cityTextField.text = profile?.city
        teamTextField.text = profile?.team
        vkField.text = profile?.vk
        tgField.text = profile?.tg
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        if let date = profile?.birthday {
            birthdayTextField.text = dateFormatter.string(from: date)
        }
        
        descriptionTextView.text = profile?.profileDescription
        userNameTextField.text = profile?.profileName
        phoneTextField.text = profile?.phone
        view.layoutIfNeeded()
    }
    
    @IBAction func skipAction(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.showMainMenu()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        spinner.startAnimating()
        if isEdit {
            editProfile()
        } else {
            editProfile()
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.showMainMenu()
        }
    }
    
    @objc func selectDateAction(picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        birthdayTextField.text = dateFormatter.string(from: picker.date)
        selectedDate = picker.date
    }
    
    func editProfile() {
        spinner.startAnimating()
        if isEdit {
            if countryTextField.text != "" {
                profile?.country = countryTextField.text
            }
            if let date = selectedDate {
                profile?.birthday = date
            }
            
            profile?.vk = vkField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            profile?.tg = tgField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            profile?.city = cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.profileDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.team = teamTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if userNameTextField.text != "" {
                profile?.profileName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let phone = phoneTextField.text, phone.isEmpty, userPostCount == 0 {
                profile?.phone = ""
            } else if let phone = phoneTextField.text, phone.isEmpty, userPostCount != 0 {
                self.showAlert(maintText: "Ошибка удаления номера", title: "Вы не можете удалить номер пока у вас есть активные объявления.", handler: nil)
            } else if let phone = phoneTextField.text, Validator.shared.validate(string: phone, pattern: Validator.Regexp.phone.rawValue) {
                profile?.phone = phoneTextField.text
            } else {
                let alert = UIAlertController(title: "Неверный формат номера телефона", message: "Формат номера: +375251234567", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        } else {
            profile?.country = countryTextField.text
            if let date = selectedDate {
                profile?.birthday = date
            }
            profile?.team = teamTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            profile?.city = cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            profile?.profileDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.profileName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.vk = vkField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.tg = tgField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if phoneTextField.text != "" {
                if let phone = phoneTextField.text, !phone.isEmpty, Validator.shared.validate(string: phone, pattern: Validator.Regexp.phone.rawValue) {
                    profile?.phone = phoneTextField.text
                } else {
                    let alert = UIAlertController(title: "Не верный формат телефона", message: "Формат номера: +375251234567", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    
        
        let manager = NetworkManager()
        guard let profile = profile else { return }
        manager.editProfile(profile: profile) {
            self.spinner.stopAnimating()
            print("Updated complete")
            manager.getCurrentUser { (profile, rrror, _) in
                self.profile = profile
                self.preloadData()
            }
            self.showPopup(isError: false, title: "Профиль обновлён")
        } failure: { error in
            print("[Edit profile]: \(error)")
            self.spinner.stopAnimating()
            self.showPopup(isError: true, title: "Не удалось обновить профиль")
        }
    }
}
