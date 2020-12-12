//
//  CategoriesPageViewController.swift
//  Squadix
//
//  Created by Illia Romanenko on 12.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class CategoriesPage: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setupDelegateData(self)
        tableView.registerCell(SimpleTextCell.self)
    }
}

extension CategoriesPage: UITableViewDataSource {
    
}

extension CategoriesPage: UITableViewDelegate {
    
}
