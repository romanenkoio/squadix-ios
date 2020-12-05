//
//  NotificationCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 5.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class NotificationCell: BaseTableViewCell {
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationImageView.makeRound()
    }
    
    func setupView(notification: Notifications) {
        switch notification.type {
        case .like:
            typeImageView.image = UIImage(named: "like_fill")
        case .decline:
            typeImageView.image = UIImage(named: "cancel")
        case .aprooved:
            typeImageView.image = UIImage(named: "confirm")
        case .systemNews:
            typeImageView.image = UIImage(named: "cancel")
        case .none:
            typeImageView.isHidden = true
        }
        
        if let picture = notification.pictureUrl {
            notificationImageView.loadImageWith(picture)
        } else {
            notificationImageView.image = UIImage(named: "avatar_placeholder")
        }
        
        messageTextLabel.text = notification.message
        timeLabel.text = Date().dateToHumanString()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationImageView.isHidden = false
    }
}
