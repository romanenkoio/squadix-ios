//
//  CustomTableViewHeaderView.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

class CustomTableHeader: UITableViewHeaderFooterView {
    
   override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.tintColor = UIColor.backgroundGray
        self.textLabel?.textColor = UIColor.black
    }
}
