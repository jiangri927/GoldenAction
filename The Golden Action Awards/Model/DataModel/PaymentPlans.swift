//
//  PaymentPlans.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


public struct PaymentPlans {
    // Votes
    public static let oneVote = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Vote-Pack-One"
    public static let tenVotes = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Vote-Pack-Ten"
    public static let fiftyVotes = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Vote-Pack-Fifty"
    public static let hundredVotes = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Vote-Pack-OneHundred"
    // Nominations
    public static let oneNom = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Nom-Pack-One"
    public static let tenNoms = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Nom-Pack-Ten"
    public static let fiftyNoms = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Nom-Pack-Fifty"
    public static let hundredNoms = "stackonapp.The-Golden-Action-Awards-Beta.PaymentPlans.Nom-Pack-OneHundred"
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [PaymentPlans.oneVote, PaymentPlans.tenVotes, PaymentPlans.fiftyVotes, PaymentPlans.hundredVotes, PaymentPlans.oneNom, PaymentPlans.tenNoms, PaymentPlans.fiftyNoms, PaymentPlans.hundredNoms]
    
    public static let store = IAPHelper(productIds: PaymentPlans.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
