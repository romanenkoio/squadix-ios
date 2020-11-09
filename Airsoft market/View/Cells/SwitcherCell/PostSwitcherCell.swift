//
//  PostSwitcherCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class PostSwitcherCell: UITableViewCell {
    @IBOutlet weak var postImage: UIImageView!
     
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(_ post: Bool) {
        postImage.image = UIImage(named: post ? "confirm" : "cancel")
    }


}
