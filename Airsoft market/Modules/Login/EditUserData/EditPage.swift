//
//  EditPage.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/4/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class EditPage: UIViewController {
    @IBOutlet weak var countryTextField: StrikeInputField!
    @IBOutlet weak var cityTextField: StrikeInputField!
    @IBOutlet weak var birthdayTextField: StrikeInputField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contatinerHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var mainSaveButton: OliveButton!
    @IBOutlet weak var saveButton: OliveButton!
    @IBOutlet weak var skipButton: WhiteButton!
    @IBOutlet weak var userNameTextField: StrikeInputField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var phoneTextField: StrikeInputField!
    
    var selectedDate: Date?
    var profile: Profile?
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.delegate = self
        
        title = "Детали"
        
        mainSaveButton.isHidden = !isEdit
        saveButton.isHidden = isEdit
        skipButton.isHidden = isEdit

        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        
        birthdayTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(selectDateAction(picker:)), for: .valueChanged)
        
        let calendar = Calendar.current
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        components.year = -10
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        datePicker.maximumDate = maxDate
        
      
        let manager = NetworkManager()
        manager.getCurrentUser { (profile, rrror, _) in
            self.profile = profile
            self.preloadData()
        }
    }
    
    func preloadData() {
        countryTextField.text = "Беларусь"
        cityTextField.text = profile?.city
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        if let date = profile?.birthday {
            birthdayTextField.text = dateFormatter.string(from: date)
        }
        
        descriptionTextView.text = profile?.profileDescription
        userNameTextField.text = profile?.profileName
        phoneTextField.text = profile?.phone
        let size = CGSize(width: descriptionTextView.frame.width, height: .infinity)
        let estimatedSize = descriptionTextView.sizeThatFits(size)
        contatinerHeight.constant = estimatedSize.height
        textViewHeight.constant = estimatedSize.height
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
        
        if isEdit {
            if countryTextField.text != "" {
                profile?.country = countryTextField.text
            }
            if let date = selectedDate {
                profile?.birthday = date
            }
            
            profile?.city = cityTextField.text
            profile?.profileDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if userNameTextField.text != "" {
                profile?.profileName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if phoneTextField.text != "" {
                profile?.phone = phoneTextField.text
            }
        } else {
            profile?.country = countryTextField.text
            if let date = selectedDate {
                profile?.birthday = date
            }
            profile?.city = cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.profileDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.profileName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            profile?.phone = phoneTextField.text
        }
    
        
        let manager = NetworkManager()
        guard let profile = profile else { return }
        manager.editProfile(profile: profile) {
            self.spinner.stopAnimating()
            print("Updated complete")
            if self.isEdit {
                self.navigationController?.popViewController(animated: true)
            }
        } failure: { error in
            print("[Edit profile]: \(error)")
            self.spinner.stopAnimating()
            PopupView(title: "", subtitle: "Не удалось обновить профиль", image: UIImage(named: "cancel")).show()
        }

    }
}

extension EditPage: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        contatinerHeight.constant = estimatedSize.height
        textViewHeight.constant = estimatedSize.height
        view.layoutIfNeeded()
    }
}
