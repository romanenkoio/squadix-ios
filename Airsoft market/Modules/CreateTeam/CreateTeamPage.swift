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
    @IBOutlet weak var saveButton: OliveButton!
    
    var isEdit = false
    var teamId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание команды"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCityLabel))
        commandCity.addGestureRecognizer(tap)
        if isEdit {
            loadTeam()
        }
    }
    
    @objc func didTapCityLabel() {
        let vc = SelectCityPage.loadFromNib()
        vc.selectAction = { [weak self] city in
            self?.commandCity.text = city.name
            self?.popController()
        }
        pushController(vc)
        if isEdit {
            loadTeam()
        }
    }
    
    func loadTeam() {
        spinner.startAnimating()
        guard let id = teamId else { return }
        networkManager.getTeamById(teamID: id) {  [weak self] team in
            self?.spinner.stopAnimating()
            self?.prefillTeam(team: team)
        } failure: {  [weak self] in
            self?.spinner.stopAnimating()
        }
    }
    
    func prefillTeam(team: Team) {
        commandName.text = team.name
        commandCity.text = team.city
        commandDescription.text = team.description
     
    }

    @IBAction func createTeam(_ sender: Any) {
        guard let name = commandName.text, let city = commandCity.text, let description = commandDescription.text, !name.isEmpty, !city.isEmpty, !description.isEmpty else { return }
        let team = Team(name: name, city: city, description: description)
        
        spinner.startAnimating()
        
        if isEdit {
            team.id = teamId ?? 0
            networkManager.editTeam(team: team) { [weak self] team in
                self?.showPopup(title: "Обновлено")
                self?.spinner.stopAnimating()
            } failure: { [weak self] in
                self?.spinner.stopAnimating()
            }
        } else {
            networkManager.createTeam(team: team) { [weak self] team in
                self?.spinner.stopAnimating()
                self?.showPopup(title: "Создано")
                self?.popController()
            } failure: { [weak self] in
                self?.spinner.stopAnimating()
            }
        }
            

    }
}
