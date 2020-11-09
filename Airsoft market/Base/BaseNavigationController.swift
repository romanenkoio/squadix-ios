//
//  BaseNavigationController.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/25/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.mainStrikeColor
        self.navigationBar.tintColor = UIColor.black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationBar.titleTextAttributes = textAttributes
//        self.navigationBar.topItem?.title = "Назад"
    }
}
