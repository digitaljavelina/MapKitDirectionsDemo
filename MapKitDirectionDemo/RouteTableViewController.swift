//
//  RouteTableViewController.swift
//  MapKitDirectionDemo
//
//  Created by Michael Henry on 12/6/15.
//  Copyright © 2015 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class RouteTableViewController: UITableViewController {
    
    var routeSteps = [MKRouteStep]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return routeSteps.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // configure the cell...
        
        cell.textLabel?.text = routeSteps[indexPath.row].instructions
        
        return cell
    }

}
