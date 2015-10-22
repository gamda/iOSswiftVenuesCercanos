//
//  DetailViewModel.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/20/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import MapKit

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
    
    func configureMap(map: MKMapView) {
        map.showsUserLocation = true
        let radius = Double((self.venue.location?.distance)!) * 10.0
        let center = CLLocationCoordinate2D(latitude: (self.venue.location?.lat)!,
                                            longitude: (self.venue.location?.lng)!)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(center, radius, radius)
        map.setRegion(coordinateRegion, animated: true)
        
        let distance = (venue.location?.distance?.description)! + "m away"
        let annotation = Annotation(coordinate: center, title: venue.name, subtitle: distance)
        map.addAnnotation(annotation)
    }
    
    func receiveVenue(venue: Venue) {
        self.venue.likes = venue.likes
        self.venue.shortURL = venue.shortURL
        self.likes = venue.likes
        self.shortURL = venue.shortURL
        self.controller.configureView()
    }
    
    func failedWithError(title: String, message: String) {
        self.controller.alert(title, message: message)
    }
}

private class Annotation: NSObject, MKAnnotation {
    @objc let coordinate: CLLocationCoordinate2D
    @objc let title: String?
    @objc let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
