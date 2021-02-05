//
//  SwipeSetup.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/9/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

class SwipeSetup {
    
    private static let instanceInner = SwipeSetup()
    
    static var instance: SwipeSetup {
        return instanceInner
    }
    
    
}
extension UIViewController: UIGestureRecognizerDelegate {
    
    func setupDownGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureDown(_:)))
        gesture.direction = .down
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(gesture)
    }
    @objc func swipeGestureDown(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    @objc func swipeGestureRight(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.navigationController?.popViewController(animated: true)
            case UISwipeGestureRecognizerDirection.down:
                // self.dismiss(animated: true, completion: nil)
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
}
