//
//  CategoryCheckboxCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class CategoryCheckboxCell: UITableViewCell {
    @IBOutlet weak var filterDescriptionLabel: UILabel!
    @IBOutlet weak var checkBoxImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupWith(_ filter: Filter) {
        checkBoxImage.image = filter.status ? UIImage(named: "checkBox_fill") : UIImage(named: "checkBox")
        filterDescriptionLabel.text = filter.category
    }
}
