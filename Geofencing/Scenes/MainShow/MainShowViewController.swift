//
//  MainShowViewController.swift
//  Geofencing
//
//  Created by msm72 on 12/28/18.
//  Copyright (c) 2018 golos. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Input & Output protocols
protocol MainShowDisplayLogic: class {
    func displaySomething(fromViewModel viewModel: MainShowModels.Something.ViewModel)
}

class MainShowViewController: UIViewController {
    // MARK: - Properties
    private let flatPanelShow: CGFloat = 0.0
    private let flatPanelHide: CGFloat = -280.0
    
    private let pickerView: UIPickerView = UIPickerView()
    private var pickerViewDataSource: [Any] = ["one", "two", "three", "seven", "fifteen"]
    
    private var settingsRadiusIndex: Int = 0
    private var settingsRadiusValue: Float = UserDefaults.standard.float(forKey: settingsRadiusKey)

    private var accessoryToolbar: UIToolbar {
        get {
            let toolbarFrame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 44.0)
            let accessoryToolbar = UIToolbar(frame: toolbarFrame)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonTapped(sender:)))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            accessoryToolbar.tintColor = .white
            accessoryToolbar.barTintColor = .lightGray
            accessoryToolbar.items = [flexibleSpace, doneButton]

            return accessoryToolbar
        }
    }
    
    var interactor: MainShowBusinessLogic?
    var router: NSObjectProtocol?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var flatPanelView: UIView!
    @IBOutlet weak var pickerTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.delegate = self
        }
    }
    
    @IBOutlet var roundButtonsCollection: [UIButton]! {
        didSet {
            self.roundButtonsCollection.forEach({ $0.layer.cornerRadius = $0.frame.height  / 2
                $0.layer.borderWidth = 1.0
                $0.layer.borderColor = UIColor.darkGray.cgColor
                $0.clipsToBounds = true
            })
        }
    }
    
    @IBOutlet weak var flatPanelViewTopConstraint: NSLayoutConstraint! {
        didSet {
            self.flatPanelViewTopConstraint.constant = self.flatPanelHide
        }
    }
    
    
    // MARK: - Class Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }

    deinit {
        print("MainShowViewController: deinit...")
    }
    
    
    // MARK: - Setup
    private func setup() {
        let viewController          =   self
        let interactor              =   MainShowInteractor()
        let presenter               =   MainShowPresenter()
        
        viewController.interactor   =   interactor
        viewController.router       =   router
        interactor.presenter        =   presenter
        presenter.viewController    =   viewController
    }
    
    private func setupUI() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = UIColor.white
        
        self.pickerTextField.inputView = pickerView
        self.pickerTextField.inputAccessoryView = accessoryToolbar
    }
    

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainViewController:  viewDidLoad run...")

        self.setupUI()
        self.loadViewSettings()
    }
    
    
    // MARK: - Custom Functions
    private func loadViewSettings() {
        let requestModel = MainShowModels.Something.RequestModel()
        interactor?.doSomething(withRequestModel: requestModel)
    }
    
    private func flatPanel(hide: Bool) {
        // Hide flat panel
        self.flatPanelViewTopConstraint.constant = hide ? self.flatPanelHide : self.flatPanelShow
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Actions
    @IBAction func settingsBarButtonItemTap(_ sender: Any) {
        print("MainViewController: settings bar button item tapped...")
    
        guard self.flatPanelViewTopConstraint.constant == self.flatPanelHide else { return }
        
        // Show flat panel
        self.flatPanel(hide: false)
    }
    
    // Picker view buttons
    @objc func onDoneButtonTapped(sender: UIBarButtonItem) {
        if self.pickerTextField.isFirstResponder {
            self.pickerTextField.resignFirstResponder()
        }

        self.flatPanelView.isUserInteractionEnabled = true
    }
    
    
    // Settings buttons
    @IBAction func settingsCurrentLocationButtonTap(_ sender: UIButton) {
        print("MainViewController: settings current location button tapped...")

//        self.flatPanelView.isUserInteractionEnabled = false
    }
    
    @IBAction func settingsEnteringGeofenceButtonTap(_ sender: UIButton) {
        print("MainViewController: settings entering geofence button tapped...")

//        self.flatPanelView.isUserInteractionEnabled = false
    }
    
    @IBAction func settingsWiFiButtonTap(_ sender: UIButton) {
        print("MainViewController: settings Wi-Fi button tapped...")

//        self.flatPanelView.isUserInteractionEnabled = false
    }
   
    @IBAction func settingsRadiusButtonTap(_ sender: UIButton) {
        print("MainViewController: settings radius button tapped...")

        self.pickerViewDataSource = Array(1...1000).compactMap({ $0 * 100 })
        self.pickerTextField.becomeFirstResponder()
        self.settingsRadiusIndex = (self.pickerViewDataSource as! [Int]).firstIndex(of: Int(self.settingsRadiusValue)) ?? 0
        
        self.pickerView.selectRow(self.settingsRadiusIndex, inComponent: 0, animated: true)
        self.flatPanelView.isUserInteractionEnabled = false
    }
    
    @IBAction func settingsReadyButtonTap(_ sender: UIButton) {
        print("MainViewController: settings ready button tapped...")
     
        // Modify stored properties
        UserDefaults.standard.set(self.settingsRadiusValue, forKey: settingsRadiusKey)
        
        // Hide flat panel
        self.flatPanel(hide: true)
    }

    @IBAction func settingsCancelButtonTap(_ sender: UIButton) {
        print("MainViewController: settings cancel button tapped...")
        
        // Hide flat panel without change stored properties
        self.flatPanel(hide: true)
    }

    @IBAction func settingsDeleteButtonTap(_ sender: UIButton) {
        print("MainViewController: settings delete button tapped...")
        
        // Clean all stored properties
        
        
        // Hide flat panel
        self.flatPanel(hide: true)
    }
}


// MARK: - MainShowDisplayLogic
extension MainShowViewController: MainShowDisplayLogic {
    func displaySomething(fromViewModel viewModel: MainShowModels.Something.ViewModel) {
        // NOTE: Display the result from the Presenter

    }
}


// MARK: - MKMapViewDelegate
extension MainShowViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "myGeotification"
//        if annotation is Geotification {
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//                let removeButton = UIButton(type: .custom)
//                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
//                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
//                annotationView?.leftCalloutAccessoryView = removeButton
//            } else {
//                annotationView?.annotation = annotation
//            }
//            return annotationView
//        }

        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
//        let geotification = view.annotation as! Geotification
//        remove(geotification)
//        saveAllGeotifications()
    }
}


// MARK: - UIPickerViewDataSource
extension MainShowViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewDataSource.count
    }
}


// MARK: - UIPickerViewDelegate
extension MainShowViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let titleString = self.pickerViewDataSource[row] as? String {
            return titleString
        }
        
        else if let titleInt = self.pickerViewDataSource[row] as? Int {
            return String(format: "%d", titleInt)
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Modify stored properties
        if let valueInt = self.pickerViewDataSource[row] as? Int {
            self.settingsRadiusIndex = row
            self.settingsRadiusValue = Float(valueInt)
        }
    }
}
