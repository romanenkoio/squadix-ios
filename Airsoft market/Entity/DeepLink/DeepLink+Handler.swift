//
//  DeepLink+Handler.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension Deeplink {
    class Handler {
        static let shared: Handler = {
            return Handler()
        }()
        
        private init() { }
        
        
        func canHandle(deepLink: Deeplink) -> Bool {
            return viewController(for: deepLink).vc != nil
        }
        
        @discardableResult
        func handle(deeplink: Deeplink, andRoute: Bool = true) -> DeeplinkRoutable? {
            
            let result = viewController(for: deeplink)
            if let vc = result.vc, andRoute {
                var style = deeplink.prefferedPresentationStyle ?? .push
                if deeplink.reuseController {
                    style = .updateCurrent
                }
                presentViewController(vc, style: style)
                result.vc?.handle(deeplink)
            } else if let url = deeplink.url {
                UIApplication.shared.open(url)
            }
            return result.vc
        }
        
        
        // MARK: - Controller search
        
        private func viewController(for deeplink: Deeplink) -> (vc: DeeplinkRoutable?, source: Source?) {
            let classToHandle: AnyClass? = classesConforms(protocol: DeeplinkRoutable.self)?.first(where: {
                return $0.canHandle(deeplink)
            })
            
            var routableVC: DeeplinkRoutable?
            var source: Source?
            
            // Check if there is any controllers in current navigation stack
            if let vc = controllerFromNavigationStack(for: classToHandle) {
                routableVC = vc
                source = .navigationBar
            }
            
            // Check if the controller is root controller in TabBar
            if routableVC == nil, let vc = controllerFromTabbar(for: classToHandle) {
                routableVC = vc
                source = .tabBar
            }
            
            if let reuse = classToHandle?.reuseExistingController(deeplink), routableVC != nil {
                deeplink.reuseController = reuse
            }
            
            if routableVC == nil {
                routableVC = classToHandle?.initControllerFromStoryboard()
                source = .tabBar
            }
            
            return (routableVC, source)
        }
    }
}

extension Deeplink.Handler {
    private func controllerFromTabbar(for vcClass: AnyClass?) -> DeeplinkRoutable? {
        guard let vcClass = vcClass, let tabBar = (UIApplication.shared.delegate as? AppDelegate)?.mainTabBar else { return nil }
        var vc: DeeplinkRoutable?
        _ = tabBar.viewControllers?.first(where: {
            if let navVC = $0 as? UINavigationController {
                vc = navVC.viewControllers.last(where: {
                    return $0.isKind(of: vcClass)
                }) as? DeeplinkRoutable
                return vc != nil
            }
            return false
        })
        return vc
    }
    
    private func controllerFromNavigationStack(for vcClass: AnyClass?) -> DeeplinkRoutable? {
        guard let vcClass = vcClass, let delegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        var vc: DeeplinkRoutable?
        if let navVC = delegate.currentViewController?.navigationController {
            vc = navVC.viewControllers.last(where: {
                return $0.isKind(of: vcClass)
            }) as? DeeplinkRoutable
        }
        return vc
    }
    
    
    // MARK: - Routing
    
    private func presentViewController(_ vc: DeeplinkRoutable, style: Deeplink.PresentationStyle = .push) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("The controller to presentation, to represent push in nil")
            return
        }
        switch style {
        case .modal:
            appDelegate.currentViewController?.present(vc, animated: true, completion: nil)
        case .push:
            pushOrPopIfExists(vc)
        case .tabBar, .updateCurrent:
            appDelegate.mainTabBar?.routeTo(vc, popToController: true)
        }
    }
    
    private func pushOrPopIfExists(_ viewControoler: UIViewController) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let navVC = appDelegate.currentViewController?.navigationController else {
            print("Current controller isn't a navigation controller")
            return
        }
        
        if navVC.viewControllers.contains(where: { $0 === viewControoler }) {
            navVC.popToViewController(viewControoler, animated: true)
        } else {
            navVC.pushViewController(viewControoler, animated: true)
        }
    }
    
    
    // MARK: - Common
    
    private func classesConforms(protocol: Protocol) -> [AnyClass]? {
        let classCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, classCount)
        
        var classes = [AnyClass]()
        for i in 0..<actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)], class_conformsToProtocol(currentClass, `protocol`) {
                classes.append(currentClass)
            }
        }
        
        allClasses.deallocate()
        print(classes)
        return classes
    }
}
