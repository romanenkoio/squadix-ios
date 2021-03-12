//
//  CommentCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 12.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit

class CommentCell: BaseTableViewCell {
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(comment: Comment) {
        if let avatar = comment.authorAvatarURL {
            authorAvatar.loadImageWith(avatar)
        } else {
            authorAvatar.image = UIImage(named: "avatar_placeholder")
        }
        authorName.text = comment.authorName
        commentTextLabel.text = comment.text
        timeLabel.text = comment.createdAt?.dateToHumanString()
    }

    @IBAction func likeAction(_ sender: Any) {
        action?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorAvatar.image = UIImage(named: "avatar_placeholder")
    }
    
    @IBAction func tapAvatarAction(_ sender: Any) {
        
    }
    
}
