//
//  BaseTableViewCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/4/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    var action: VoidBlock?
    let generator = UINotificationFeedbackGenerator()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        action = nil
        _ = getSubviewsOfView(view: self).map({ $0.interactions = [] }) 
    }
}
