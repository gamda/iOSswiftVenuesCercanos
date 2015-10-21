//
//  MasterViewModel.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/21/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

protocol MasterController {
    func reloadData()
    func alert(title: String, message: String, showButton: Bool)
    func dismissAlert()
}

class MasterViewModel: NSObject, UITableViewDataSource, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, NearbyVenuesDelegate {
    
    var canUseLocationServices: Bool = false
    var venues: [Venue]? = nil
    var controller: MasterController
    var locationManager: CLLocationManager!
    var managedObjectContext: NSManagedObjectContext
    
    init(controller: MasterController, context: NSManagedObjectContext) {
        self.controller = controller
        self.managedObjectContext = context
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func refresh() {
        if canUseLocationServices {
            locationManager.requestLocation()
            self.controller.alert("Un momento",
                                message: "Actualizando venues con tu ubicación",
                                showButton: false)
        }
        else {
            self.controller.alert("Ubicación",
                                message: "El app necesita acceder a tu ubicación para mostrar los venues cercanos",
                                showButton: true)
        }
    }
    
    // MARK: - NearbyVenuesDelegate
    
    func receiveVenues(venues: [Venue]) {
        self.venues = venues
        self.controller.reloadData()
        self.controller.dismissAlert()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionInfo = self.fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
        return self.venues?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
//        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//        cell.textLabel!.text = object.valueForKey("timeStamp")!.description
        let venue = self.venues![indexPath.row]
        cell.textLabel!.text = venue.name
        cell.detailTextLabel!.text = (venue.location?.distance?.description)! + " m de distancia"
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            canUseLocationServices = true
            self.refresh()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let location = locations[0]
        VenuesService.nearbyVenues(location.coordinate.latitude,
            lng: location.coordinate.longitude,
            delegate: self)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: ", error)
    }
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
}