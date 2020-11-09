//
//  TableView+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/23/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func registerCell(_ cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass.self), bundle: nil)
        self.register(nib, forCellReuseIdentifier: String(describing: cellClass.self))
    }
    
    func setupDelegateData(_ controller: UIViewController) {
        self.delegate = controller as? UITableViewDelegate
        self.dataSource = controller as? UITableViewDataSource
        self.tableFooterView = UIView()
    }
}
