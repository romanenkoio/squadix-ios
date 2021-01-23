//
//  UIViewController+Extension.swift
//  Squadix
//
//  Created by Illia Romanenko on 23.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}
