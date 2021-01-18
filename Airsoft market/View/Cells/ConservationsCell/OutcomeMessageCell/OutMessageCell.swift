//
//  OutMessageCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 10.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ActiveLabel

class OutMessageCell: BaseTableViewCell {
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mesageLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 15
        timeLabel.text = Date().dateToHumanString()
        
        mesageLabel.handleURLTap { url in
            let type = Deeplink.DeeplinkType.checkLinkType(url: url)
            
            switch type {
            case .event, .post, .product:
                Deeplink.Handler.shared.handle(deeplink: Deeplink(url: url))
            case .unknow:
                UIApplication.shared.open(url)
            }
        }
    }
}
