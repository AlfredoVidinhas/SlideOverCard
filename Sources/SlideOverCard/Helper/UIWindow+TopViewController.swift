//
//  UIWindow+TopViewController.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 20/03/24.
//

import UIKit

extension UIWindow {
    /// Returns the topmost view controller in the window's hierarchy
    internal func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedVC = self.presentedViewController {
            return presentedVC.topMostViewController()
        }
        if let navController = self as? UINavigationController {
            return navController.visibleViewController?.topMostViewController() ?? navController
        }
        if let tabController = self as? UITabBarController {
            return tabController.selectedViewController?.topMostViewController() ?? tabController
        }
        return self
    }
}
