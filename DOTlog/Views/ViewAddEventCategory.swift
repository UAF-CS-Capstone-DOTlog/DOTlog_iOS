//
//  ViewAddEventCategory.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/29.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventCategory: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var categories : [String] = []
	var currentCategory : String? = nil

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?
		if categories[indexPath.row] == currentCategory {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedCategoryCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("categoryCell") as! UITableViewCell?
		}
		cell?.textLabel?.text = categories[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentCategory = cell?.textLabel?.text
		performSegueWithIdentifier("SegueCategoryToAddEvent", sender: self)

	}

	func resetPage() {
		let categoryFetch = NSFetchRequest (entityName:"CategoryEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			categories = Array<String>() // Clear old array
			for category in categoryResults {
				categories.append(category.category_title)
			}
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destinationViewController = segue.destinationViewController as! ViewAddEvent
		if segue.identifier == "SegueCategoryToAddEvent" {
			destinationViewController.UIFieldCategory.text = currentCategory
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}