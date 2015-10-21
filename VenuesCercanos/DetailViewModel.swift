//
//  DetailViewModel.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/20/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation

class DetailViewModel {
    var venue: Venue
    var name: String
    
    init(venue: Venue!) {
        self.venue = venue
        self.name = venue.name
    }
}
