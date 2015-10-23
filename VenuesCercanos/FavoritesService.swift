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
        var managedVenues: [AnyObject] = []
        var venues: [Venue] = []
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try managedVenues = managedObjectContext.executeFetchRequest(fetchRequest)
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        for v in managedVenues as! [NSManagedObject] {
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

