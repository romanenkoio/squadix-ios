//
//  InMessageCell.swift
//  Squadix
//
//  Created by Illia Romanenko on 10.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class InMessageCell: BaseTableViewCell {
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 15
        timeLabel.text = Date().dateToHumanString()
    }
}
