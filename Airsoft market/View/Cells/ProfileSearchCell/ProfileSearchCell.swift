//
//  ProfileSearchCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ProfileSearchCell: BaseTableViewCell {
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileRegionLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileAvatar.makeRound()
    }

    override func prepareForReuse() {
        
    }
    
}
