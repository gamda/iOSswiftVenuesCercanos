//
//  DetailViewController.swift
//  VenuesCercanos
//
//  Created by Daniel Garcia on 10/19/15.
//  Copyright © 2015 Daniel Garcia. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
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
                self.viewModel = DetailViewModel(venue: detail)
            }
            else {
                self.viewModel!.venue = detail
            }
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let label = self.detailDescriptionLabel {
            label.text = viewModel!.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

