//
//  SearchAlg.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/3/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
//import AlgoliaSearch
import SearchTextField

class SearchAlg {
    
    private static let instanceInner = SearchAlg()
    
    static var instance: SearchAlg {
        return instanceInner
    }
 /*   let productionClient = Client(appID: "0L3X8OR2A4", apiKey: "76b50d5f3ca14ae116a6eb298f08bbc1")
    //let client = Client(appID: "0X1E31NHC3", apiKey: "59f6b4de0da98c550812049865381424")
    let client = Client(appID: "9ABFPLXP4E", apiKey: "da54313ace5daa89d8f907d0b88fb31c")

    var completionHandler: (([String : Any]?, Error?) -> ())!
    
    
    func loadCityQuery(query: String?, completion: @escaping ([SearchTextFieldItem]?) -> Void) {
        let cityIndex = AlgoliaRef.cities.reference()
        let que = Query(query: query)
        
        if query != "" {
            guard (query?.count)! <= 15 else {
                completion([])
                return
            }
            self.completionHandler = { (content: [String : Any]?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion(nil)
                    return
                }
                let hits = content!["hits"] as? [Any] ?? []
                print(hits)
                if hits.count != 0 {
                    var searches = [SearchTextFieldItem]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let city = hit["city"] as? String ?? "N/A"
                        let state = hit["state"] as? String ?? "N/A"
                        let cluster = hit["cluster"] as? String ?? "000"
                        let item = SearchTextFieldItem(title: city, subtitle: state, cluster: cluster)
                        if !searches.contains(item) {
                            searches.insert(item, at: searches.count)
                        }
                    }
                    //let popular = SearchTextFieldItem(title: "Popular", subtitle: "", cluster: "000")
                    //searches.append(popular)
                    completion(searches)
                } else {
                    completion(nil)
                }
                /*if let cursor = content!["cursor"] as? String {
                    cityIndex.browse(from: cursor, completionHandler: self.completionHandler)
                    print("Page 2")
                } */
            }
            cityIndex.browse(query: que, completionHandler: self.completionHandler)
        }
        
        /*cityIndex.browse(query: que) { (response, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                print(response)
                completion()
            }
        } */
        
        
    }
    func loadUserQuery(query: String?, completion: @escaping ([SearchTextFieldItem]?) -> Void) {
        let cityIndex = AlgoliaRef.users.reference()
        let que = Query(query: query)
        
        if query != "" {
            guard (query?.count)! <= 15 else {
                completion([])
                return
            }
            self.completionHandler = { (content: [String : Any]?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion(nil)
                    return
                }
                let hits = content!["hits"] as? [Any] ?? []
                print(hits)
                if hits.count != 0 {
                    var searches = [SearchTextFieldItem]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let fullName = hit["fullName"] as? String ?? "N/A"
                        let cityState = hit["cityState"] as? String ?? "N/A"
                        let region = hit["region"] as? String ?? "000"
                        let phone = hit["phone"] as? String ?? "N/A"
                        let email = hit["email"] as? String ?? "N/A"
                        let uid = hit["uid"] as? String ?? "N/A"
                        let item = SearchTextFieldItem(titleFullName: fullName, cityStateSubtitle: cityState, email: email, phone: phone, cluster: region, uidPerson: uid)
                       // let item = SearchTextFieldItem(title: city, subtitle: state, cluster: cluster)
                        if !searches.contains(item) {
                            searches.insert(item, at: searches.count)
                        }
                    }
                    
                    completion(searches)
                } else {
                    completion(nil)
                }
                
            }
            cityIndex.browse(query: que, completionHandler: self.completionHandler)
        }
        
    }
    func nominationsSearch(query: Query?, completion: @escaping ([Nominations]) -> Void) {
        let nominationIndex = self.client.index(withName: "Nominations")
        if query != nil {
            self.completionHandler = { (content: [String : Any]?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion([])
                    return
                }
                let hits = content!["hits"] as? [Any] ?? []
                print(hits)
                if hits.count != 0 {
                    var searches = [Nominations]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let item = Nominations(dict: hit)
                        if !searches.contains(item) {
                            searches.insert(item, at: 0)
                        }
                    }
                    completion(searches)
                } else {
                    completion([])
                }
                /*if let cursor = content!["cursor"] as? String {
                 cityIndex.browse(from: cursor, completionHandler: self.completionHandler)
                 print("Page 2")
                 } */
            }
            nominationIndex.browse(query: query!, completionHandler: self.completionHandler)
        }
    } */
    
}

extension SearchTextFieldItem: Equatable { }

public func ==(lhs: SearchTextFieldItem, rhs: SearchTextFieldItem) -> Bool {
    return ((lhs.title == rhs.title) && (lhs.subtitle == rhs.subtitle))

}
