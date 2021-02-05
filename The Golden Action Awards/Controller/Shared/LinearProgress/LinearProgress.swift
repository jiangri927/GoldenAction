//
//  LinearProgress.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import LinearProgressBarMaterial

class LinearProgress: NSObject, NSCoding {
    
    let linearBar: LinearProgressBar
    let task: DispatchFactory
    var width: CGFloat
    var height: CGFloat
    
    init(height: CGFloat, width: CGFloat) {
        self.width = width
        self.height = height
        self.linearBar = LinearProgressBar()
        self.task = ThreadFactory.ui_userInteract.generate(priority: 0)
        self.linearBar.backgroundProgressBarColor = Colors.app_color.generateColor()
        self.linearBar.progressBarColor = Colors.app_text.generateColor()
        self.linearBar.heightForLinearBar = height
        self.linearBar.widthForLinearBar = width
    }
    init(linear: LinearProgressBar, width: CGFloat, height: CGFloat) {
        self.linearBar = linear
        self.width = width
        self.height = height
        self.task = ThreadFactory.ui_userInteract.generate(priority: 0)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let wid = aDecoder.decodeDouble(forKey: "width")
        let hi = aDecoder.decodeDouble(forKey: "height")
        let linear = aDecoder.decodeObject(forKey: "linearBar") as? LinearProgressBar ?? LinearProgress(height: CGFloat(hi), width: CGFloat(wid)).linearBar
        self.init(linear: linear, width: CGFloat(wid), height: CGFloat(hi))
        
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Double(self.width), forKey: "width")
        aCoder.encode(Double(self.height), forKey: "height")
        aCoder.encode(self.linearBar, forKey: "linearBar")
    }
    func startAnimation() {
        self.linearBar.startAnimation()
    }
    func stopAnimation() {
        self.linearBar.stopAnimation()
    }
}
