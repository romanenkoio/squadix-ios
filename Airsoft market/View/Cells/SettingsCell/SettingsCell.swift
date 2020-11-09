//
//  SettingsCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/29/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class SettingsCell: BaseTableViewCell {
    @IBOutlet weak var actionImageArrow: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        action = nil
    }
    
    @IBAction func callAction(_ sender: Any) {
        action?()
    }
}
