//
//  ProductImageCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import SDWebImage



class ProductImageCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.cornerRadius = 10
    }
    
    func setupImage(with url: String) {
        productImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder"))
    }
    
    override func prepareForReuse() {
        productImageView.image = UIImage(named: "placeholder")
    }
    
}

