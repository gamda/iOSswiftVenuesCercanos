//
//  GetVenues.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import Alamofire

private let clientID = "hidden"
private let clientSecret = "hidden"
private let baseURL = "https://api.foursquare.com/v2/venues/"

private let errorTitle = "Error buscando venues"
private let errorMessageForEmptyBody = "No se recibieron datos del servidor. Intenta más tarde"

protocol ErrorReporting {
    func failedWithError(title: String, message: String)
}

protocol NearbyVenuesDelegate: ErrorReporting {
    func receiveVenues(venues: [Venue])
}

protocol VenueDelegate: ErrorReporting {
    func receiveVenue(venue: Venue)
}

class VenuesService {
    
    static func nearbyVenues(lat: Double, lng: Double, delegate: NearbyVenuesDelegate) {
        var venues = [Venue]()
        Alamofire.request(.GET,
                          baseURL + "search",
                          parameters: ["client_id": clientID,
                                       "client_secret": clientSecret,
                                       "v": 20151019,
                                       "intent": "browse",
                                       "radius": 500,
                                       "ll": String(format: "%.2f,%.2f", lat, lng)])
            .responseJSON { response in
                guard response.result.error == nil else {
                    delegate.failedWithError(errorTitle,
                        message: (response.result.error?.localizedDescription)!)
                    return
                }
                guard let value = response.result.value else {
                    delegate.failedWithError(errorTitle, message: errorMessageForEmptyBody)
                    return
                }
                let answer = value["response"] as? [String:AnyObject] ?? ["venues": []]
                let jsonVenues = answer["venues"] as? NSArray ?? []
                for venue in jsonVenues {
                    // venue is always a dictionary, at least with the 'name' keyword
                    // so force-unwrapping is safe
                    let v = venue as! [String:AnyObject]
                    venues.append(self.venueFromJSON(v))
                }
                delegate.receiveVenues(venues.sort(<))
            }
    }
    
    static func venue(id: String, delegate: VenueDelegate) {
        Alamofire.request(.GET,
                           baseURL + id,
                           parameters: ["client_id": clientID,
                                        "client_secret": clientSecret,
                                        "v": 20151019])
            .responseJSON{ response in
                guard response.result.error == nil else {
                    delegate.failedWithError(errorTitle,
                        message: (response.result.error?.localizedDescription)!)
                    return
                }
                guard let value = response.result.value else {
                    delegate.failedWithError(errorTitle, message: errorMessageForEmptyBody)
                    return
                }
                let answer = value["response"] as? [String:AnyObject] ?? ["venue": []]
                let jsonVenue = answer["venue"] as! [String:AnyObject]
                let shortURL = jsonVenue["shortURL"] as? String
                let jsonLikes = jsonVenue["likes"] as! [String:AnyObject]
                let likes = jsonLikes["count"] as? Int
                let venue = venueFromJSON(jsonVenue)
                venue.shortURL = shortURL
                venue.likes = likes
                delegate.receiveVenue(venue)
            }
    }
    
    private static func venueFromJSON(venue: [String:AnyObject]) -> Venue {
        let id = venue["id"] as? String ?? ""
        let name = venue["name"] as! String
        let jsonLocation = venue["location"] as? [String:AnyObject]
        let location = locationFromJSON(jsonLocation)
        return Venue(id: id, name: name, location: location)
    }
    
    private static func locationFromJSON(jsonLocation: [String:AnyObject]?) -> Location {
        var location = Location()
        if let json = jsonLocation {
            location.lat = valueForKey(json, key: "lat") as? Double
            location.lng = valueForKey(json, key: "lng") as? Double
            location.address = valueForKey(json, key: "address") as? String
            location.crossStreet = valueForKey(json, key: "crossStreet") as? String
            location.city = valueForKey(json, key: "city") as? String
            location.state = valueForKey(json, key: "state") as? String
            location.country = valueForKey(json, key: "country") as? String
            location.postalCode = valueForKey(json, key: "postalCode") as? String
        }
        return location
    }
    
    private static func valueForKey(dict: [String:AnyObject], key: String) -> AnyObject? {
        // This function helps avoid clutter 'if let...' statements in locationFromJSON
        guard let value = dict[key] else {
            return nil
        }
        return value
    }
}