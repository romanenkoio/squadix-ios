//
//  MyProfileCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ImageSlideshow

class MyProfileCell: BaseTableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var adminBadgeLabel: UILabel!
    @IBOutlet weak var avatarSlider: ImageSlideshow!
    
    var avatarAction: VoidBlock?
    var showAvatarAction: VoidBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func avatarChangeAction(_ sender: Any) {
         avatarAction?()
    }
    
    override func prepareForReuse() {
        action = nil
        avatarAction = nil
        showAvatarAction = nil
    }
    
    @IBAction func showAvatar(_ sender: Any) {
        showAvatarAction?()
    }
    
}
