//
//  BaseTabBarViewController.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/26/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = UIColor.mainStrikeColor
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.black
        self.viewControllers = VCFabric.loadTabBarItems()
    }
    
    func routeTo(_ routableController: UIViewController, popToController: Bool = false) {
        let index = viewControllers?.firstIndex(where: {
            if let navVC = $0 as? UINavigationController {
                let result = (navVC.viewControllers.first(where: {
                    return $0 == routableController
                }))
                if popToController, let result = result {
                    navVC.popToViewController(result, animated: false)
                }
                return result != nil
            }
            return false
        })
        if let index = index {
            selectedIndex = index
        }
    }
}
