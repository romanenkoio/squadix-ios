//
//  DebugCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/12/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class DebugCell: BaseTableViewCell {
    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
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
