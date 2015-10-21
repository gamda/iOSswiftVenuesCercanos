//
//  DetailViewModel.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/20/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation

protocol DetailController: ControllerAlertMethods {
    func configureView()
}

class DetailViewModel: VenueDelegate {
    var venue: Venue
    var controller: DetailController
    var name: String
    var likes: Int?
    var shortURL: String?
    
    init(venue: Venue!, controller: DetailController) {
        self.venue = venue
        self.controller = controller
        self.name = venue.name
        self.likes = venue.likes
        self.shortURL = venue.shortURL
        if let id = self.venue.id {
            VenuesService.venue(id, delegate: self)
        }
    }
    
    func receiveVenue(venue: Venue) {
        self.venue = venue
        self.likes = venue.likes
        self.shortURL = venue.shortURL
        self.controller.configureView()
    }
    
    func failedWithError(title: String, message: String) {
        self.controller.alert(title, message: message)
    }
}
