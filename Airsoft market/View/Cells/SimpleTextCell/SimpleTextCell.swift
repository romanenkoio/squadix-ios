//
//  SimpleTextCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/2/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ActiveLabel

class SimpleTextCell: UITableViewCell {
    @IBOutlet weak var simpleTextLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        simpleTextLabel.numberOfLines = 0
        simpleTextLabel.enabledTypes = [.url]
        simpleTextLabel.customize { label in
            label.handleURLTap { url in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func prepareForReuse() {
        simpleTextLabel.textColor = .black
    }
    
    func setupTextWith(_ text: String) {
        simpleTextLabel.text = text
    }
}
