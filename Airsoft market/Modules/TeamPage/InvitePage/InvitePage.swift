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
    
    var acceptAction: VoidBlock?
    var declineAction: VoidBlock?
    var showTeamAction: VoidBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamAvatarImage.makeRound()
    }

    @IBAction func acceptAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.acceptAction?()
        }
    }
    
    @IBAction func declineAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.declineAction?()
        }
    }
    
    @IBAction func showTeamAction(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.showTeamAction?()
        }
    }
    
}
