//
//  UIColor+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 6/1/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    open class var mainStrikeColor: UIColor {
         return UIColor(named: "mainStrikeColor")!
    }
    
    open class var backgroundGray: UIColor {
         return UIColor(named: "strikeGrayColor")!
    }
    
    open class var promoColor: UIColor {
         return UIColor(named: "selectedProductColor")!
    }
    
    open class var backgroundScribe: UIColor {
         return UIColor(named: "backgroundColor")!
    }
    
    open class var mainScribe: UIColor {
         return UIColor(named: "mainColor")!
    }
}
