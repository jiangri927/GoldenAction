//
//  Payment.swift
//  The Golden Action Awards
//
//  Created by Lee Sheng Jin on 2019/8/7.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit
import Alamofire

class Payment {
    // pk_test_Ggw24Zp9LLUXPXg0Aj9NCdVl00luVj0k0w    pk_live_6RFRUzBWJvnXThGf56Dgeybo
    class func createCharge(_ id: String, _ amount: Int, completion: @escaping (_ res: String?) -> Void) {
        let header = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer sk_live_UqbRxJW67nFxYc1sxeSMg3fJ00N72dHwKW"
        ]
        let params: [String: Any] = [
            "amount": amount,
            "currency": "usd",
            "source": id
        ]
        Alamofire.request("https://api.stripe.com/v1/charges", method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
            let info = response.result.value as! NSDictionary
            switch response.result {
                
            case .success:
                completion(nil)
                break
            case .failure( _):
                completion(info.value(forKey: "message") as? String ?? "Charge failed")
                break
            }
        }
    }
}
