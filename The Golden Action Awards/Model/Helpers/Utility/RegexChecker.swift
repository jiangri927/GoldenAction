//
//  RegexChecker.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation


enum RegexChecker {
    
    case email(text: String?)
    case password_uppercase(text: String?)
    case password_lowercase(text: String?)
    case password_numbers(text: String?)
    case password_count(text: String?)
    case phone_number(text: String?)
    
    func check() -> Bool {
        switch self {
        case .email(let text):
            guard text != nil else {
                return false
            }
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: text)
            
        case .password_uppercase(let text):
            guard text != nil else {
                return false
            }
            let passRegex = "(?=.*[A-Z]).{1,}"
            return NSPredicate(format: "SELF MATCHES %@", passRegex).evaluate(with: text)
        case .password_lowercase(let text):
            guard text != nil else {
                return false
            }
            let passRegex = "(?=.*[a-z]).{1,}"
            return NSPredicate(format: "SELF MATCHES %@", passRegex).evaluate(with: text)
        case .password_numbers(let text):
            guard text != nil else {
                return false
            }
            let passRegex = "(?=.*[0-9]).{1,}"
            return NSPredicate(format: "SELF MATCHES %@", passRegex).evaluate(with: text)
        case .password_count(let text):
            guard text != nil else {
                return false
            }
            if text!.count >= 6 {
                return true
            } else {
                return false
            }
            
        case .phone_number(let text):
            guard text != nil else {
                return false
            }
            let phoneRegex = "^\\d{3}\\d{3}\\d{4}$"
            let countryCodeRegex = "^\\d{2)\\d{3}\\d{3}\\d{4}$"
            return (NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: text) || NSPredicate(format: "SELF MATCHES %@", countryCodeRegex).evaluate(with: text))
        }
        
        
    }
    
    
}
