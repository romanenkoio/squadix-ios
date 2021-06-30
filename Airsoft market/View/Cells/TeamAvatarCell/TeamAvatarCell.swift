//
//  TeamAvatarCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow

class TeamAvatarCell: BaseTableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    func setupCell(team: Team) {
        teamNameLabel.text = team.name

        if !team.teamAvatar.isEmpty {
            avatarImage.loadImageWith(team.teamAvatar)
        } else {
            avatarImage.image = UIImage(named: "team_placeholder")
        }
       
        avatarImage.makeRound()
        guard let country = team.country, let city = team.city else { return }
        regionLabel.text = "\(country), \(city)"
    }
}
