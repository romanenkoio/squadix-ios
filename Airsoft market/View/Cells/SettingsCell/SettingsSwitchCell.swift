//
//  SettingsSwitchCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/29/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class SettingsSwitchCell: UITableViewCell {
    @IBOutlet weak var settingsSwitchLabel: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
    var action: VoidBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func prepareForReuse() {
        action = nil
    }

    @IBAction func switchAction(_ sender: Any) {
          action?()
    }
}
