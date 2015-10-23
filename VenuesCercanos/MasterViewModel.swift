//
//  MasterViewModel.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/21/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol MasterController: ControllerAlertMethods {
    func reloadData()
}

class MasterViewModel: NSObject, UITableViewDataSource, CLLocationManagerDelegate, NearbyVenuesDelegate {
    
    var canUseLocationServices: Bool = false
    var venues: [Venue]
    var controller: MasterController
    var locationManager: CLLocationManager
    
    init(controller: MasterController) {
        self.venues = FavoritesService.favorites()
        self.controller = controller
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func refresh() {
        if canUseLocationServices {
            locationManager.requestLocation()
        }
        else {
            self.controller.alert("Ubicación",
                                message: "El app necesita acceder a tu ubicación para mostrar los venues cercanos")
        }
    }
    
    // MARK: - NearbyVenuesDelegate
    
    func receiveVenues(venues: [Venue]) {
        self.venues = self.appendVenuesWithoutDuplicates(venues)
        self.controller.reloadData()
        self.controller.dismissAlert()
    }
    
    func appendVenuesWithoutDuplicates(array: [Venue]) -> [Venue]{
        var setOfIds: Set<String> = Set()
        for favorite in self.venues {
            setOfIds.insert(favorite.id!)
        }
        print(setOfIds)
        
        let duplicatesRemoved: [Venue] =
            Array(array).filter { (v) in !(setOfIds.contains(v.id!)) }
        self.venues = self.venues + duplicatesRemoved
        
        return self.venues.sort(<)
    }
    
    func failedWithError(title: String, message: String) {
        self.controller.alert(title, message: message)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CustomTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let venue = self.venues[indexPath.row]
        cell.lblName!.text = venue.name
        let d = String(format: "%.2f m de distancia", (venue.location?.distance)!)
        cell.lblDistance!.text = d
        if venue.isFavorite { // !venue.isFavorite doesn't work 0.o that's why I set + in storyboard
            cell.btnSave.setTitle("-", forState: .Normal)
        }
        else {
            cell.btnSave.setTitle("+", forState: .Normal)
        }
        cell.btnSave!.tag = indexPath.row
        cell.btnSave!.addTarget(self, action: "addOrDelete:", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func addOrDelete(sender: UIButton) {
        let venue = self.venues[sender.tag]
        if venue.isFavorite {
            print("remove", venue.name)
        }
        else {
            FavoritesService.saveNewFavoriteVenue(venue)
            sender.setTitle("-", forState: .Normal)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            canUseLocationServices = true
            self.refresh()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let location = locations[0]
        VenuesService.nearbyVenues(location.coordinate.latitude,
            lng: location.coordinate.longitude,
            delegate: self)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(location.coordinate.latitude, forKey: "lat")
        defaults.setDouble(location.coordinate.longitude, forKey: "lng")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.controller.alert("Error:", message: error.localizedDescription)
    }
}