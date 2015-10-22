//
//  Venue.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import CoreLocation

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
}

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
    
    init(id: String?, name: String, location: Location?) {
        self.id = id
        self.name = name
        self.location = location
    }
}

func ==(x: Venue, y: Venue) -> Bool {
    return x.id == y.id
}

func <(x: Venue, y: Venue) -> Bool {
    return x.location?.distance < y.location?.distance
}