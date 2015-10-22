//
//  DetailViewController.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, DetailController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblShortURL: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var viewModel: DetailViewModel? = nil

    var detailItem: Venue? {
        didSet {
            // Update the view model.
            self.update()
        }
    }
    
    func update() {
        self.updateViewModel()
        self.configureView()
    }
    
    func updateViewModel() {
        if let detail = self.detailItem {
            if viewModel == nil {
                self.viewModel = DetailViewModel(venue: detail, controller: self)
            }
            else {
                self.viewModel!.venue = detail
            }
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let label = self.lblName {
            label.text = viewModel!.name
        }
        if let label = self.lblLikes {
            if let likes = viewModel!.likes {
                label.text = "Likes: " + likes.description
            }
            else {
                label.text = "Likes: N/A"
            }
        }
        if let label = self.lblShortURL {
            label.text = viewModel!.shortURL
        }
    }
    
    var alert: UIAlertController? = nil
    
    func alert(title: String, message: String) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Default) { (_) in }
        alert!.addAction(cancelAction)
        self.presentViewController(alert!, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        if let alert = self.alert {
            alert.dismissViewControllerAnimated(true, completion: nil )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.update()
        self.viewModel?.configureMap(map)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

