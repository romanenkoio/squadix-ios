//
//  ContactCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/4/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class ContactCell: BaseTableViewCell {
    @IBOutlet weak var contactTypeImage: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    var contact: Contact!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupWith(_ contact: Contact) {
        self.contact = contact
        contactLabel.text = contact.method.rawValue
    }
}
