//
//  FavoritesService.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/22/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
private let managedObjectContext: NSManagedObjectContext = appDelegate.managedObjectContext

class FavoritesService {
    
    static func favorites() -> [Venue] {
        var venues: [Venue] = []
        
        for v in fetchedResultsController.fetchedObjects as! [NSManagedObject] {
            let newVenue = Venue.venueFromManagedObject(v)
            venues.append(newVenue)
        }
        
        return venues.sort(<)
    }
    
    static func saveNewFavoriteVenue(venue: Venue) {
        venue.insertManagedVenueToManagedContext(managedObjectContext)
        do {
            try managedObjectContext.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
}

// MARK: - Fetched results controller

private var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
        return _fetchedResultsController!
    }
    
    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: managedObjectContext)
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        aFetchedResultsController.delegate = self
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
private var _fetchedResultsController: NSFetchedResultsController? = nil
