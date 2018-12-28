//
//  MainViewController.swift
//  Geofencing
//
//  Created by msm72 on 12/28/18.
//  Copyright © 2018 golos. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - Properties
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentLocationBarButtonItem: UIBarButtonItem! {
        didSet {
            self.currentLocationBarButtonItem.isEnabled = false
        }
    }
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainViewController:  viewDidLoad run...")

    }
    
    
    // MARK: - Actions
    @IBAction func currentLocationBarButtonItemTap(_ sender: UIBarButtonItem) {
        print("MainViewController: current location bar button item tapped...")
    }
    
    @IBAction func settingsBarButtonItemTap(_ sender: UIBarButtonItem) {
        print("MainViewController: settings bar button item tapped...")
    }
}
