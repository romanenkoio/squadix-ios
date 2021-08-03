//
//  InvitePage.swift
//  Squadix
//
//  Created by Illia Romanenko on 14.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class InvitePage: BaseViewController {
    @IBOutlet weak var teamAvatarImage: UIImageView!
    @IBOutlet weak var inviteDescription: UILabel!
    @IBOutlet weak var inviteTextLabel: UILabel!
    
    var teamID: Int?
    var inviteAction: ((Bool) -> Void)?
    var showTeamAction: VoidBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamAvatarImage.makeRound()
        guard let team = teamID else { return }
        networkManager.getTeamById(teamID: team) { team in
            guard let team = team.name else { return }
            self.inviteTextLabel.text = "Вас приглашают присоединиться к команде \"\(team)\""
        }
    }

    @IBAction func acceptAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.inviteAction?(true)
        }
    }
    
    @IBAction func declineAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.inviteAction?(false)
        }
    }
    
    @IBAction func showTeamAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.showTeamAction?()
        }
    }
    
}
