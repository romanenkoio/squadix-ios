//
//  UINavigation+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func pushViewControllerWithFlipAnimation(viewController:UIViewController) {
        self.pushViewController(viewController
            , animated: false)
        if let transitionView = self.view{
            UIView.transition(with:transitionView, duration: 0.8, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
    
    func popViewControllerWithFlipAnimation() {
        self.popViewController(animated: false)
        if let transitionView = self.view{
            UIView.transition(with:transitionView, duration: 0.8, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
    }
}
