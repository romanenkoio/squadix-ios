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
    @IBOutlet weak var mainView: UIView!
    
    var avatarAction: VoidBlock?
    var networkManager = NetworkManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationImageView.makeRound()
    }
    
    func setupView(notification: DasboardNotification) {
        mainView.backgroundColor = notification.isReaded ? .white : .promoColor 
        switch notification.type {
        case .like:
            typeImageView.image = UIImage(named: "like_fill")
            avatarAction = {
                guard let id = notification.profileId, let top = self.navigationController()?.topViewController else { return }
                top.navigationController?.pushViewController(VCFabric.getProfilePage(for: id), animated: true)
            }
        case .decline:
            notificationImageView.image =  UIImage(named: "decline")
        case .aprooved:
            notificationImageView.image =  UIImage(named: "ok")
            action = {
                if let url = notification.url {
                    Deeplink.Handler.shared.handle(deeplink:  Deeplink(url: URL(string: url)!))
                }
            }
        case .system:
            typeImageView.isHidden = true
            action = {
                if let urlString = notification.url, let url = URL(string: urlString) {
                    Deeplink.Handler.shared.handle(deeplink: Deeplink(url: url))
                }
            }
            notificationImageView.image = UIImage(named: "AppIcon")
        case .report:
            notificationImageView.image = UIImage(named: "report")
            action = {
                if let url = notification.url {
                    Deeplink.Handler.shared.handle(deeplink:  Deeplink(url: URL(string: url)!))
                }
            }
        default:
            print("Error")
        }
        
        typeImageView.isHidden = true
        messageTextLabel.text = notification.message
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let notificationDate = notification.time, let date = formatter.date(from: notificationDate) {
            timeLabel.text = date.dateToHumanString()
        } else {
            timeLabel.text = ""
        }
    }
    
    @IBAction func avatarAction(_ sender: Any) {
        avatarAction?()
    }
    
    @IBAction func cellAction(_ sender: Any) {
        action?()
    }
    
    func getProduct(url: URL) {
        guard let postID = url.path.matches(for: "[0-9]+").first, let id = Int(postID) else { return }
        networkManager.getProductByID(postID: id) { [weak self] product in
            self?.notificationImageView.loadImageWith(product.picturesUrl[0])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationImageView.isHidden = false
        notificationImageView.image = UIImage(named: "placeholder")
        avatarAction = nil
    }
}
