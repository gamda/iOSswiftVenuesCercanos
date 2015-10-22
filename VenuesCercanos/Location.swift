//
//  Location.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/22/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

struct Location {
    // All values are optional because they might not be in the JSON object received
    var lat: Double?
    var lng: Double?
    var distance: Double {
        let defaults = NSUserDefaults.standardUserDefaults()
        let lat = defaults.doubleForKey("lat")
        let lng = defaults.doubleForKey("lng")
        let userCoord = CLLocation(latitude: lat, longitude: lng)
        let venueCoord = CLLocation(latitude: self.lat!, longitude: self.lng!)
        
        let zero = 0.0
        if lat == zero || lng == zero || self.lat == zero || self.lng == zero {
            return zero
        }
        
        return userCoord.distanceFromLocation(venueCoord)
    }
    var address: String?
    var crossStreet: String?
    var city: String?
    var state: String?
    var country: String?
    var postalCode: String?
    
    func managedLocationForManagedContext(context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)
        let newManagedLocation = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context)
        if let lat = self.lat {
            newManagedLocation.setValue(lat, forKey: "lat")
        }
        if let lng = self.lng {
            newManagedLocation.setValue(lng, forKey: "lng")
        }
        if let address = self.address {
            newManagedLocation.setValue(address, forKey: "address")
        }
        if let crossStreet = self.crossStreet {
            newManagedLocation.setValue(crossStreet, forKey: "crossStreet")
        }
        if let city = self.city {
            newManagedLocation.setValue(city, forKey: "city")
        }
        if let state = self.state {
            newManagedLocation.setValue(state, forKey: "state")
        }
        if let country = self.country {
            newManagedLocation.setValue(country, forKey: "country")
        }
        if let postalCode = self.postalCode {
            newManagedLocation.setValue(postalCode, forKey: "postalCode")
        }
        return newManagedLocation
    }
    
    static func locationFromManagedObject(object: NSManagedObject) -> Location {
        var newLocation = Location()
        newLocation.lat = object.valueForKey("lat") as? Double
        newLocation.lng = object.valueForKey("lng") as? Double
        newLocation.address = object.valueForKey("address") as? String
        newLocation.crossStreet = object.valueForKey("crossStreet") as? String
        newLocation.city = object.valueForKey("city") as? String
        newLocation.state = object.valueForKey("state") as? String
        newLocation.country = object.valueForKey("country") as? String
        newLocation.postalCode = object.valueForKey("postalCode") as? String
        return newLocation
    }
}