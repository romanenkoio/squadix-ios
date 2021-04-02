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
    @IBOutlet weak var avatarSlider: ImageSlideshow!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    func setupCell(team: Team) {
        avatarSlider.setupView()
        teamNameLabel.text = team.name
        if !team.teamAvatar.isEmpty {
            avatarSlider.setupImagesWithUrls([team.teamAvatar])
        } else {
            if let image = UIImage(named: "team_placeholder") {
                avatarSlider.setupImagesWithImages([image])
            }
        }
       
        avatarSlider.makeRound()
        regionLabel.text = "\(team.country), \(team.city)"
    }
}
