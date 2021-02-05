//
//  AdminFeatures.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/25/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import EasyPostApi
import PDFKit



class AdminFeatures {
    
    var shippingCity: String
    var shippingZip: String
    var shippingState: String
    var shippingAddress: String
    var person: Person
    
    init(person: Person, city: String, zip: String, state: String, address: String) {
        self.person = person
        self.shippingZip = zip
        self.shippingCity = city
        self.shippingState = state
        self.shippingAddress = address
    }
    
    
    
    
    
    
    
    
    
}


