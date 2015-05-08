//
//  ViewAddEventHub.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class ViewAddEventHub: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var hubs : [String] = []
	
	var currentAirport : String?
	var currentHub : String?
	var currentDistrict : String?
	var currentRegion : String?
	
	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return hubs.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?
		if hubs[indexPath.row] == currentHub {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedHubCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("hubCell") as! UITableViewCell?
		}
		cell?.textLabel?.text = hubs[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentHub = cell?.textLabel?.text
		performSegueWithIdentifier("SegueHubsToAirports", sender: self)
	}

	func resetPage() {
		let hubFetch = NSFetchRequest (entityName:"HubEntry")
		if let hubResults = managedObjectContext!.executeFetchRequest(hubFetch, error:nil) as? [HubEntry]{
			hubs = Array<String>() // Clear old array
			for hub in hubResults {
				if currentDistrict == hub.district.district_name || currentDistrict == nil {
					hubs.append(hub.hub_name)
				}
			}
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueHubsToAirports" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventAirport
			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = currentAirport
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}