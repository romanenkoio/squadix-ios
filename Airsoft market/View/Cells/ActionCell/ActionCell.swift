//
//  ActionCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ActionCell: BaseTableViewCell {
    @IBOutlet weak var actionDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func didAction(_ sender: Any) {
        action?()
    }
}
