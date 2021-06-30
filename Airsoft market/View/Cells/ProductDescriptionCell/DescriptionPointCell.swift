//
//  DescriptionPointCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import ActiveLabel

class DescriptionPointCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var commandLabel: UIButton!
    @IBOutlet weak var teamStack: UIStackView!
    @IBOutlet weak var teamImage: UIImageView!
    
    var searchAction: VoidBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func findTeamPersonsAction(_ sender: Any) {
        searchAction?()
    }
    
}

