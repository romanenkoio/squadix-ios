//
//  LikeCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/31/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class LikeCell: BaseTableViewCell {
    @IBOutlet weak var likeImage: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func tapLike(_ sender: Any) {
        action?()
    }
    
    
}
