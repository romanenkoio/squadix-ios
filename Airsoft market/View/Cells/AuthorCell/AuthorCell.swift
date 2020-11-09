//
//  AuthorCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class AuthorCell: BaseTableViewCell {
    @IBOutlet weak var profileAvatarImage: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContent()
    }

    func setupContent() {
        profileAvatarImage.makeRound()
    }
    
    override func prepareForReuse() {
        action = nil
    }
    
    @IBAction func tapAvatarAction(_ sender: Any) {
        action?()
    }
}
