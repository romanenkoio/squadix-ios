//
//  PeopleCollectionCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class PeopleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var profileID = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(people: TeamMember) {
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.borderWidth = 2
        avatarImage.layer.borderColor = UIColor.white.cgColor
        
        if let avatar = people.avatar {
            avatarImage.loadImageWith(avatar)
        } else {
            avatarImage.image = UIImage(named: "avatar_placeholder")
        }
        usernameLabel.text = people.profileName
        avatarImage.makeRound()
        profileID = people.id
    }
    
    @IBAction func showProfileAction(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("The controller to presentation, to represent push in nil")
            return
        }
        appDelegate.currentViewController?.navigationController?.pushViewController(VCFabric.getProfilePage(for: profileID), animated: true)
    }
    
}
