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
        let fetchRequest = fetchRequestWithVenueEntityAndSortAscending()
        
        let venues: [Venue] = fetchVenuesForFetchRequest(fetchRequest)
        
        return venues.sort(<)
    }
    
    static func saveNewFavoriteVenue(venue: Venue) -> Bool {
        venue.insertManagedVenueToManagedContext(managedObjectContext)
        return saveContext()
    }
    
    static func deleteVenueWithId(id: String) -> Bool {
        let fetchRequest = fetchRequestWithVenueEntityAndSortAscending()
        let idPredicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = idPredicate
        
        let venues: [NSManagedObject] = fetchManagedObjectsForFetchRequest(fetchRequest)
        for v in venues {
            managedObjectContext.deleteObject(v)
        }
        return saveContext()
    }
    
    private static func fetchRequestWithVenueEntityAndSortAscending() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    private static func fetchVenuesForFetchRequest(request: NSFetchRequest) -> [Venue] {
        let managedVenues = fetchManagedObjectsForFetchRequest(request)
        var venues: [Venue] = []
        
        for v in managedVenues {
            let newVenue = Venue.venueFromManagedObject(v)
            venues.append(newVenue)
        }
        return venues
    }
    
    private static func fetchManagedObjectsForFetchRequest(
            request: NSFetchRequest) -> [NSManagedObject] {
        var managedVenues: [AnyObject] = []
        do {
            try managedVenues = managedObjectContext.executeFetchRequest(request)
        } catch {
            print("Unresolved error \(error)")
        }
        return managedVenues as! [NSManagedObject]
    }
    
    private static func saveContext() -> Bool {
        do {
            try managedObjectContext.save()
        } catch {
            print("Unresolved error \(error)")
            return false
        }
        return true
    }
    
}

