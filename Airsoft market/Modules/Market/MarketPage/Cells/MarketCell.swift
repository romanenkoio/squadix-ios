//
//  MarketCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class MarketCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var productDateLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var commentCountView: UIView!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImage.roundedBottomCornerImage()
        cellView.dropShadow()
        commentCountView.roundedCorners()
    }

 
    
}
