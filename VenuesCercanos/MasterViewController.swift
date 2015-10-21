//
//  MasterViewController.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, MasterController {
    
    var viewModel: MasterViewModel? = nil

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Venues Cercanos"
        self.viewModel = MasterViewModel(controller: self, context: managedObjectContext!)
        self.tableView.dataSource = self.viewModel
        let btnRefresh = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                         target: self.viewModel,
                                         action: "refresh")
        self.navigationItem.rightBarButtonItem = btnRefresh
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MasterController
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    var alert: UIAlertController? = nil
    
    func alert(title: String, message: String, showButton: Bool) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        if showButton {
            let cancelAction = UIAlertAction(title: "OK", style: .Default) { (_) in }
            alert!.addAction(cancelAction)
        }
        self.presentViewController(alert!, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        if let alert = self.alert {
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let venue = self.viewModel!.venues![indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = venue
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}

