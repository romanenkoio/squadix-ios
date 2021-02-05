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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Восстановление пароля"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func restoreAction(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty, !Validator.shared.validate(string: email, pattern: Validator.Regexp.email.rawValue) else {
            PopupView.init(title: "", subtitle: "Проверьте правильность email", image: UIImage(named: "cancel")).show()
            return
        }
        
    }
}
