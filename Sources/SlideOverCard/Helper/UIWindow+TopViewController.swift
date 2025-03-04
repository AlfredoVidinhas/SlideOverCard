//
//  UIWindow+TopViewController.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 20/03/24.
//

import UIKit

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
