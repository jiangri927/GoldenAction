//
//  UIViewControllerExtension.swift
//  The Golden Action Awards
//
//  Created by Lee Sheng Jin on 2019/8/14.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
