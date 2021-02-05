//
//  Cities.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftKeychainWrapper
//import AlgoliaSearch
import SearchTextField
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging




class Cities: NSObject, NSCoding {
    
    var clusterNumber: String
    var cityState: String
    
    init(dict: [String : Any]) {
        self.clusterNumber = dict["cluster"] as? String ?? ""
        let city = dict["city"] as? String ?? ""
        let state = dict["state"] as? String ?? ""
        self.cityState = "\(city), \(state)"
    }
    init(userLocDict: [String : Any]) {
        self.clusterNumber = userLocDict["cluster"] as? String ?? "000"
        self.cityState = userLocDict["cityState"] as? String ?? "Popular"
    }
    init(cluster: String, cityState: String) {
        self.clusterNumber = cluster
        self.cityState = cityState
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let cluster = aDecoder.decodeObject(forKey: "cluster") as? String ?? "000"
        let cityState = aDecoder.decodeObject(forKey: "cityState") as? String ?? "Popular"
        
        self.init(cluster: cluster, cityState: cityState)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.clusterNumber, forKey: "cluster")
        aCoder.encode(self.cityState, forKey: "cityState")
    }
    func toDictionary() -> [String : Any] {
        return [
            "cluster": self.clusterNumber,
            "cityState": self.cityState
            
        ]
    }
    
    
    
}

extension Cities {
    class func loadCityQuery(query: String?, completion: @escaping ([SearchTextFieldItem]?) -> Void) {
      /*  let cityIndex = AlgoliaRef.cities.reference()
        var completionHandler: (([String : Any]?, Error?) -> ())!
        let que = Query(query: query)
        if query != "" {
            completionHandler = { (content: [String : Any]?, error: Error?) in
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
                    let popular = SearchTextFieldItem(title: "Popular", subtitle: "", cluster: "000")
                    searches.append(popular)
                    completion(searches)
                } else {
                    completion(nil)
                }
            }
            cityIndex.browse(query: que, completionHandler: completionHandler)
        } */
        
        
    }
    class func loadCitiesString(completion: @escaping ([String]) -> Void) {
        
    }
    class func loadKeychainCities(completion: @escaping ([Cities], Error?) -> Void) {
        if let data = KeychainWrapper.standard.data(forKey: Keys.cluster_250.key) {
            let cities = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Cities] ?? []
            completion(cities, nil)
        } else {
            Cities.loadEncodedCities { (cities, error) in
                completion(cities, error)
            }
        }
    }
    class func loadEncodedCities(completion: @escaping ([Cities], Error?) -> Void) {
        Alamofire.request("https://goldenactionawards.com/locations.json").responseJSON { (response) in
            guard response.error == nil else {
                print(response.error!.localizedDescription)
                completion([], response.error)
                return
            }
            if let json = response.result.value {
                if let json = json as? [Any] {
                    var cities = [Cities]()
                    for dict in json {
                        if let d = dict as? [String : Any] {
                            let city = Cities(dict: d)
                            if !cities.contains(city) {
                                cities.append(city)
                            }
                        }
                    }
                    let data = NSKeyedArchiver.archivedData(withRootObject: cities)
                    KeychainWrapper.standard.set(data, forKey: Keys.cluster_250.key)
                    completion(cities, nil)
                }
            } else {
                completion([], nil)
            }
        }
    }
    
    
    class func loadCities(name: String, completion: @escaping ([Cities]) -> Void) {
        let pt = Bundle.main.path(forResource: name, ofType: "json")
        let url = URL(fileURLWithPath: pt!)
        do {
            let data = try NSData(contentsOf: url, options: .mappedIfSafe)
            //let dict = try NSDictionary(contentsOf: url, error: ())
            do {
                
                if let dict = try JSONSerialization.jsonObject(with: data as Data, options: .init(rawValue: 0)) as? [Any] {
                    var clusters = [Cities]()
                    
                    for school in dict {
                        let schoo = school as! [String : Any]
                        let cluster = Cities(dict: schoo)
                        if !clusters.contains(cluster) {
                            clusters.append(cluster)
                        }
                        
                    }
                    
                    let data: Data = NSKeyedArchiver.archivedData(withRootObject: clusters) as Data
                    print(data)
                    Storage.storage().reference().child("cluster").putData(data, metadata: nil, completion: { (meta, error) in
                        guard error == nil else {
                            print("---------------------->")
                            print(error!.localizedDescription)
                            return
                        }
                        guard meta != nil else {
                            print("Meta Tag is Nil Load Cities Function in Cities Data Model")
                            return
                        }
                        print(meta!)
                    })
                    print("---------------------->")
                    print(clusters.count)
                    
                    print("---------------------->")
                    completion(clusters)
                    
                    
                }
            } catch let error as NSError {
                completion([])
                print("\(error)")
            }
            
        } catch let error as NSError {
            completion([])
            print("\(error.localizedDescription)")
        }
    }
    class func saveToStorage(data: Data, completion: @escaping () -> Void) {
        let ref = GoldenStorage.clusters_temp.reference()
        ref.putData(data)
        completion()
    }
}










