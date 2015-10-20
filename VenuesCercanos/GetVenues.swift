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

class GetVenues {
    
    static func nearbyVenues() {
        Alamofire.request(.GET,
                          "https://api.foursquare.com/v2/venues/search?near=Mexico",
                          parameters: ["client_id": clientID,
                                       "client_secret": clientSecret,
                                       "v": 20151019])
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
                let answer = value["response"] as! [String:AnyObject]
                let venues = answer["venues"] as! NSArray
                print(venues.dynamicType)
                for v in venues {
                    print(v)
                }
            }
    }
}