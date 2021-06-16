//
//  CreateTeamPage.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class CreateTeamPage: BaseViewController {
    @IBOutlet weak var commandName: UITextField!
    @IBOutlet weak var commandCity: UITextField!
    @IBOutlet weak var commandDescription: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание команды"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCityLabel))
        commandCity.addGestureRecognizer(tap)
    }
    
    @objc func didTapCityLabel() {
        let vc = SelectCityPage.loadFromNib()
        vc.selectAction = { [weak self] city in
            self?.commandCity.text = city.name
            self?.popController()
        }
        pushController(vc)
    }

    @IBAction func createTeam(_ sender: Any) {
        guard let name = commandName.text, let city = commandCity.text, let description = commandDescription.text, !name.isEmpty, !city.isEmpty, !description.isEmpty else { return }
        let team = Team(name: name, city: city, description: description)
        
        spinner.startAnimating()
        networkManager.createTeam(team: team) { [weak self] team in
            self?.spinner.stopAnimating()
        } failure: { [weak self] in
            self?.spinner.stopAnimating()
        }
    }
}
