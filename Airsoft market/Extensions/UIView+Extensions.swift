//
//  UIView+Extensions.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeRound() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
    func dropShadow(){
        layer.cornerRadius = 10
        layer.borderColor = UIColor.black.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
    }
    
    func roundedBottomCornerImage() {
        layer.cornerRadius = 10
        layer.maskedCorners = [  .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    func roundedTopCornerImage() {
        layer.cornerRadius = 10
        layer.maskedCorners = [  .layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func roundedCorners() {
        layer.cornerRadius = 10
        layer.maskedCorners = [  .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    func getConvertedFrame(fromSubview subview: UIView) -> CGRect? {
        guard subview.isDescendant(of: self) else {
            return nil
        }
        
        var frame = subview.frame
        if subview.superview == nil {
            return frame
        }
        
        var superview = subview.superview
        while superview != self {
            frame = superview!.convert(frame, to: superview!.superview)
            if superview!.superview == nil {
                break
            } else {
                superview = superview!.superview
            }
        }
        
        return superview!.convert(frame, to: self)
    }
    
    func controller() -> UIViewController? {
          if let nextViewControllerResponder = next as? UIViewController {
              return nextViewControllerResponder
          }
          else if let nextViewResponder = next as? UIView {
              return nextViewResponder.controller()
          } else  {
              return nil
          }
      }
    
    func navigationController() -> UINavigationController? {
        if let controller = controller() {
            return controller.navigationController
        }
        else {
            return nil
        }
    }
    
    func getSubviewsOfView(view: UIView) -> [UIView] {
        var subviewArray = [UIView]()
        if view.subviews.count == 0 {
            return subviewArray
        }
        for subview in view.subviews {
            subviewArray += self.getSubviewsOfView(view: subview)
            subviewArray.append(subview)
        }
        return subviewArray
    }
}

extension UIView: SkeletonAppearance {
    @objc @discardableResult func drawSkeleton() -> CALayer {
        let skeletonLayer = layer.sublayer(named: skeletonLayerName) ?? CALayer(named: skeletonLayerName)
        guard !isSkeletonVisible else { return skeletonLayer }
        
        skeletonLayer.frame = bounds
        layer.addSublayer(skeletonLayer)
        
        let colorAnim = CABasicAnimation(keyPath: "backgroundColor")
        colorAnim.repeatCount = 1000
        colorAnim.duration = 1
        colorAnim.fromValue = #colorLiteral(red: 0.6907934546, green: 0.7354480624, blue: 0.5957186818, alpha: 1).cgColor
        colorAnim.toValue = #colorLiteral(red: 0.6907934546, green: 0.7354480624, blue: 0.5957186818, alpha: 1).cgColor
        colorAnim.autoreverses = true
        colorAnim.isRemovedOnCompletion = false
        skeletonLayer.add(colorAnim, forKey: "colorAnimation")
        
        return skeletonLayer
    }
    
    func makeDefault() {
        layer.sublayer(named: skeletonLayerName)?.removeFromSuperlayer()
    }
}
