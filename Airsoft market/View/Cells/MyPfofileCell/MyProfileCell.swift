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
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var adminBadgeLabel: UILabel!
    @IBOutlet weak var avatarSlider: ImageSlideshow!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var tgButton: UIButton!
    
    var avatarAction: VoidBlock?
    var showAvatarAction: VoidBlock?
    var tgAction: VoidBlock?
    var vkAction: VoidBlock?
    
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
    
    func setupCell(profile: Profile) {
        vkButton.isHidden = profile.vk == nil
        tgButton.isHidden = profile.tg == nil
    }
    
    @IBAction func vkAction(_ sender: Any) {
        vkAction?()
    }
    
    @IBAction func tgAction(_ sender: Any) {
        tgAction?()
    }
}
