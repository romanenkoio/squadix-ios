//
//  ProfileSearchCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileSearchCell: BaseTableViewCell {
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRegionLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileAvatar.makeRound()
    }
    
    func setupCell(profile: Profile) {
        if let pic = profile.profilePictureUrl {
            profileAvatar.sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "avatar_placeholder"))
        } else {
            profileAvatar.image = UIImage(named: "avatar_placeholder")
        }
        
        adminLabel.isHidden = !profile.roles.contains(.admin)
        adminLabel.text = profile.roles.contains(.admin) ? Common.Roles.admin.displayRoleName : ""
        profileNameLabel.text = profile.profileName
        
        var reg = ""
        
        if let region = profile.country {
            reg = region
        }
        if let city = profile.city, !city.isEmpty {
            reg += ", \(city)"
        }
        profileRegionLabel.text = reg
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileAvatar.image = nil
    }
    
}
