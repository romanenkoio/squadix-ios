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
    
    var avatarAction: VoidBlock?
    var networkManager = NetworkManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationImageView.makeRound()
    }
    
    func setupView(notification: DasboardNotification) {
        switch notification.type {
        case .like:
            typeImageView.image = UIImage(named: "like_fill")
            avatarAction = {
                guard let id = notification.profileId, let top = self.navigationController()?.topViewController else { return }
                top.navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
            }
        case .decline:
            notificationImageView.image = UIImage(named: "decline")
        case .aprooved:
            notificationImageView.image = UIImage(named: "ok")
        case .system:
            notificationImageView.image = UIImage(named: "AppIcon")
        default:
            print("Error")
        }
        
        typeImageView.isHidden = notification.type != .some(.like)

        messageTextLabel.text = notification.message
        timeLabel.text = Date().dateToHumanString()
    }
    
    @IBAction func avatarAction(_ sender: Any) {
        avatarAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationImageView.isHidden = false
        notificationImageView.image = UIImage(named: "avatar_placeholder")
        avatarAction = nil
    }
}
