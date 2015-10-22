//
//  Venue.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import CoreData


class Venue: Comparable {
    /*
     * Venue is a Class instead of Location because it can be passed by reference. For 
     * example from the Master view controller to the Detail view controller.
     * https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-ID82
     * id and location properties are optional because they might not be in the JSON
     * object: "API will sometimes return venues that only have a name due to the 
     * "venueless" checkin feature."
     */
    var id: String?
    var name: String
    var location: Location?
    var shortURL: String?
    var likes: Int?
    var isFavorite: Bool = false
    
    init(id: String?, name: String, location: Location?) {
        self.id = id
        self.name = name
        self.location = location
    }
    
    func insertManagedVenueToManagedContext(context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: context)
        let newManagedVenue = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context)
        
        newManagedVenue.setValue(self.name, forKey: "name")
        if let id = self.id {
            newManagedVenue.setValue(id, forKey: "id")
        }
        if let location = self.location {
            newManagedVenue.setValue(
                location.insertManagedLocationToManagedContext(context), forKey: "location")
        }
        // shortURL and likes are retrieved by detail view model so no need to save them
        return newManagedVenue
    }
    
    static func venueFromManagedObject(object: NSManagedObject) -> Venue {
        let id = object.valueForKey("id") as? String
        let name = object.valueForKey("name") as! String
        var location: Location? = nil
        let locObject = object.valueForKey("location") as? NSManagedObject
        if let locationObject = locObject {
            location = Location.locationFromManagedObject(locationObject)
        }
        let v = Venue(id: id, name: name, location: location)
        v.isFavorite = true
        return v
    }
    
}

func ==(x: Venue, y: Venue) -> Bool {
    return x.id == y.id
}

func <(x: Venue, y: Venue) -> Bool {
    return x.location?.distance < y.location?.distance
}