//
//  UIViewController+Dismiss.swift
//  BFWControls
//
//  Created by Tom Brodhurst-Hill on 12/5/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

public extension UIViewController {
    
    @IBAction func dismiss(_ sender: UIControl?) {
        dismiss(animated: true) {}
    }
    
    @objc func removeDismiss() {
        // TODO: Cater for multiple leftBarButtonItems.
        if let selector = navigationItem.leftBarButtonItem?.action,
            selector == #selector(UIViewController.dismiss(_:))
        {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    var firstViewController: UIViewController {
        return (self as? UINavigationController)?.viewControllers.first ?? self
    }
    
    var readiedForPush: UIViewController {
        removeDismiss()
        return firstViewController
    }
    
}

public extension UINavigationController {
    
    override func removeDismiss() {
        viewControllers.first?.removeDismiss()
    }
    
}

public extension UITabBarController {
    
    override func removeDismiss() {
        viewControllers?.forEach { $0.removeDismiss() }
    }
    
}
