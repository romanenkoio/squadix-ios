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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImage.roundedBottomCornerImage()
        cellView.dropShadow()
    }
    
    func setupProduct(_ item: MarketProduct) {
        productNameLabel.text = item.productName
        let reg = item.productRegion == nil ? "Город не указан" : item.productRegion
        regionLabel.text = reg
        
        productImage.loadImageWith(item.picturesUrl[0])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: item.createdAt) {
            productDateLabel.text = date.dateToHumanString()
        }
        
        if let price = item.price {
            productPriceLabel.text = "\(price) руб"
        }
        selectionStyle = .none
    }
    
    func setupPromo(_ item: MarketProduct) {
        productNameLabel.text = item.productName
        productImage.loadImageWith(item.picturesUrl[0])
        if let price = item.price {
            productPriceLabel.text = "\(price) руб"
        }
        selectionStyle = .none
        cellView.backgroundColor = .promoColor
        productDateLabel.text = "Товар партнёра"
        regionLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        regionLabel.isHidden = false
        productDateLabel.isHidden = false
        cellView.backgroundColor = UIColor.white
    }
}
