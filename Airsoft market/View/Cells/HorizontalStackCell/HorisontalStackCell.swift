//
//  HorisontalStackCell.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/1/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class HorisontalStackCell: UITableViewCell {
    @IBOutlet weak var cellStackView: UIStackView!
    
    @IBOutlet weak var salesStack: UIStackView!
    @IBOutlet weak var salesCountLabel: UILabel!
    
    @IBOutlet weak var postStack: UIStackView!
    @IBOutlet weak var postCountLabel: UILabel!
    var postAction: VoidBlock?
    var productAction: VoidBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let postTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePostTap))
        postStack.addGestureRecognizer(postTap)
        
        let productTap = UITapGestureRecognizer(target: self, action: #selector(self.handleProductTap))
        salesStack.addGestureRecognizer(productTap)
    }

    @objc func handlePostTap() {
        postAction?()
    }
    
    @objc func handleProductTap() {
        productAction?()
    }
    
    override func prepareForReuse() {
        postAction = nil
        productAction = nil
    }
}
