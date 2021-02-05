//
//  Tasks.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/3/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation


class Tasks: NSObject, NSCoding {
    
    var ui_que: DispatchQueue
    var data_que: DispatchQueue
    var utility_que: DispatchQueue
    
    
    init(ui: DispatchQueue, data: DispatchQueue, util: DispatchQueue) {
        self.ui_que = ui
        self.data_que = data
        self.utility_que = util
    }
    
    override convenience init() {
        let ui_que = DispatchQueue(label: "ui", qos: DispatchQoS.init(qosClass: .userInteractive, relativePriority: 0), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        let data_que = DispatchQueue(label: "data", qos: DispatchQoS.init(qosClass: .userInitiated, relativePriority: -3), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        let utility_que = DispatchQueue(label: "util", qos: DispatchQoS.init(qosClass: .utility, relativePriority: -6), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        self.init(ui: ui_que, data: data_que, util: utility_que)
    }

   required convenience init?(coder aDecoder: NSCoder) {
        let ui = aDecoder.decodeObject(forKey: "UI") as? DispatchQueue ?? DispatchQueue(label: "ui", qos: DispatchQoS.init(qosClass: .userInteractive, relativePriority: 0), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        let data = aDecoder.decodeObject(forKey: "DATA") as? DispatchQueue ?? DispatchQueue(label: "data", qos: DispatchQoS.init(qosClass: .userInitiated, relativePriority: -3), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        let util = aDecoder.decodeObject(forKey: "UTIL") as? DispatchQueue ?? DispatchQueue(label: "util", qos: DispatchQoS.init(qosClass: .utility, relativePriority: -6), attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: .main)
        self.init(ui: ui, data: data, util: util)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.ui_que, forKey: "UI")
        aCoder.encode(self.data_que, forKey: "DATA")
        aCoder.encode(self.utility_que, forKey: "UTIL")
    }
    
    
    
}
