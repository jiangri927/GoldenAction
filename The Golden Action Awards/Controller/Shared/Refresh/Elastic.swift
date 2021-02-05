//
//  Elastic.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import DGElasticPullToRefresh
import SAConfettiView
//import AlgoliaSearch
import SwiftKeychainWrapper
import SwiftEventBus


class Elastic: DGElasticPullToRefreshLoadingView {
    
    var tableView: UITableView
    var refreshItem: DispatchWorkItem
    var loadingView: DGElasticPullToRefreshLoadingViewCircle
    var vc: UIViewController
    
    
    init(tableView: UITableView, vc: UIViewController, refreshItem: DispatchWorkItem) {
        self.tableView = tableView
        self.refreshItem = refreshItem
        self.loadingView = DGElasticPullToRefreshLoadingViewCircle()
        self.loadingView.tintColor = Colors.app_color.generateColor()
        self.vc = vc
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func startAnimating() {
        super.startAnimating()
        self.tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            //self?.elasticRefresh(tableView: (self?.tableView)!)
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100), execute: (self?.refreshItem)!)
            }, loadingView: self.loadingView)
        self.tableView.dg_setPullToRefreshFillColor(Colors.black.generateColor())
        self.tableView.dg_setPullToRefreshBackgroundColor(Colors.app_text.generateColor())
    }
    
    override func stopLoading() {
        super.stopLoading()
        self.tableView.dg_stopLoading()
    }
    override func setPullProgress(_ progress: CGFloat) {
        super.setPullProgress(100)
    }
    
}

