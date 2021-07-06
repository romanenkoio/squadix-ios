//
//  FullPictureCell.swift
//  Squadix
//
//  Created by Artur Radziukhin on 3.07.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import UIKit
import SDWebImage

class FullPictureCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    var fullscreenImageView = UIImageView()
    
    var pictureURL = "" {
        didSet {
            fullscreenImageView.sd_setImage(with: URL(string: pictureURL), placeholderImage: UIImage(named: "placeholder"), options: [], completed: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(fullscreenImageView)
        fullscreenImageView.frame = CGRect(x: 0, y: 0, width: frame.width - 20, height: frame.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fullscreenImageView.contentMode = .scaleAspectFit
    }

}
