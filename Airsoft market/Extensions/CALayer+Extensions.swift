//
//  CALayer+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

protocol SkeletonAppearance where Self: UIView {
    @discardableResult
    func drawSkeleton() -> CALayer
    func makeDefault()
}

extension SkeletonAppearance {
    var isSkeletonVisible: Bool {
        return layer.sublayer(named: skeletonLayerName) != nil
    }
    
    var skeletonLayerName: String {
        return "_SkeletonAppearanceLayer"
    }
}

extension CALayer {
    func sublayer(named: String) -> CALayer? {
        return sublayers?.first(where: { $0.name == named })
    }
    
    public convenience init(named: String) {
        self.init()
        name = named
    }
}

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        xPoint: CGFloat = 0,
        yPoint: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: xPoint, height: yPoint)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let deltaX = -spread
            let rect = bounds.insetBy(dx: deltaX, dy: deltaX)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
