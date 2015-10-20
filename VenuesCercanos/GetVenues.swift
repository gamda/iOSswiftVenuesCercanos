//
//  GetVenues.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import Alamofire

private var clientID = "M3AW50FNGJUGETXH3MEMFN0A3GGFN2AF1RGBKGJX5R335O55"
private var clientSecret = "FTGCJYFX4UXPQ3AZ1251ISJXYJZHDR4BLE3MFWJ1L3VHQ3P0"

protocol GetVenuesDelegate {
    func receiveVenueData(venues: [Venue])
}

class GetVenues {
    
    static var delegate: GetVenuesDelegate? = nil
    
    static func nearbyVenues(lat: Double, lng: Double) {
        var venues = [Venue]()
        Alamofire.request(.GET,
                          "https://api.foursquare.com/v2/venues/search",
                          parameters: ["client_id": clientID,
                                       "client_secret": clientSecret,
                                       "v": 20151019,
                                       "intent": "browse",
                                       "radius": 500,
                                       "ll": String(format: "%.2f,%.2f", lat, lng)])
            .responseJSON { response in
                guard let value = response.result.value else {
                    print("Error: did not receive data")
                    return
                }
                guard response.result.error == nil else {
                    print("error fetching venues")
                    print(response.result.error)
                    return
                }
                let answer = value["response"] as? [String:AnyObject] ?? ["venues": []]
                let jsonVenues = answer["venues"] as? NSArray ?? []
                for venue in jsonVenues {
                    // venue is always a dictionary, at least with the 'name' keyword
                    // so force-unwrapping is safe
                    let v = venue as! [String:AnyObject]
                    venues.append(venueFromJSON(v))
                }
                if let d = delegate {
                    d.receiveVenueData(venues)
                }
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
            location.distance = valueForKey(json, key: "distance") as? Double
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
        // This function helps avoid clutter 'if' statements in locationFromJSON
        guard let value = dict[key] else{
            return nil
        }
        return value
    }
}