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
import Reachability
import SystemConfiguration.CaptiveNetwork

// MARK: - Input & Output protocols
class MainShowViewController: UIViewController {
    // MARK: - Properties
    private let flatPanelShow: CGFloat = 0.0
    private let flatPanelHide: CGFloat = -280.0
    
    private var isAlertViewShow: Bool = false {
        didSet {
            if oldValue == true && UserDefaults.standard.bool(forKey: locationAuthStatusKey) {
                self.showAlertView(title: "Allow Location Access", message: "App 'Geofencing' needs access to your location. Turn On Location Services in your device Settings", actionType: .settings)
            }
        }
    }
    
    private let pickerView: UIPickerView = UIPickerView()
    private var pickerViewDataSource: [Any] = [String]()
    
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
    
    var reachability: Reachability!

    private let locationManager = CLLocationManager()
    private var model = MainShowModel()
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var flatPanelView: UIView!
    @IBOutlet weak var pickerTextField: UITextField!
    
    // UIButtons
    @IBOutlet weak var settingsWiFiButton: UIButton!
    @IBOutlet weak var settingsRadiusButton: UIButton!
    @IBOutlet weak var settingsGeofenceButton: UIButton!
    @IBOutlet weak var settingsCurrentLocationButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.delegate = self
            self.mapView.userTrackingMode = .follow
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped(sender:)))
//            gestureRecognizer.delegate = self
            self.mapView.addGestureRecognizer(gestureRecognizer)
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
    deinit {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        self.reachability.stopNotifier()
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = UIColor.white
        
        self.pickerTextField.inputView = pickerView
        self.pickerTextField.inputAccessoryView = accessoryToolbar
    }
    
    private func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.startUpdatingLocation()
    }

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        self.setupUI()
        
        // LocationManager
        self.setupLocationManager()
        
        // Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Reachability
        self.reachability = Reachability.init()
        
        do {
            try self.reachability.startNotifier()
        } catch {
            print("MainViewController: unable to start notifier")
        }
    }
    
    
    // MARK: - Custom Functions
    private func flatPanel(hide: Bool) {
        // Hide flat panel
        self.flatPanelViewTopConstraint.constant = hide ? self.flatPanelHide : self.flatPanelShow
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func delay(_ delay:Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    private func getAllWiFiNames() -> [String]? {
        var ssids: [String]? = [String]()
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceName = interface as? String {
                    ssids?.append(interfaceName)
                }
            }
        }
        
        return ssids
    }
    
    private func showAlertView(title: String = "Info", message: String, actionType: ActionType = .none) {
        self.isAlertViewShow = true

        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            switch actionType {
            case .settings:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { success in
                        print("MainShowViewController: function: \(#function), line: \(#line): iOS Settings opened: \(success)")
                    })
                }

            case .geofence:
                self.settingsEnteringGeofenceButtonTap(self.settingsGeofenceButton)
                
            default:
                self.isAlertViewShow = false
                break
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        self.settingsWiFiButton.isEnabled = self.reachability.connection == .wifi
        self.settingsGeofenceButton.isEnabled = self.reachability.connection == .wifi
        self.settingsCurrentLocationButton.isEnabled = self.reachability.connection == .wifi
    }
    
    private func showAlertViewWithTextField() {
        let alert = UIAlertController(title: "Info", message: "Enter Manual Location", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationHandler)
        alert.textFields?.first?.autocapitalizationType = .sentences
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.flatPanelView.isUserInteractionEnabled = true
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, text.isEmpty {
                self.showAlertView(title: "Info", message: "Enter geofence", actionType: .geofence)
            }
            
            else {
                self.getCoordinateFrom(address: alert.textFields!.first!.text!) { [weak self] coordinate, error in
                    guard let strongSelf = self else { return }
                    
                    guard error == nil else {
                        strongSelf.showAlertView(title: "Error", message: error!.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        print("MainShowViewController: function: \(#function), line: \(#line): settingsGeofence = \(coordinate!)")
                        strongSelf.model.settingsGeofence = coordinate
                        
                        strongSelf.addPointAnnotation(location: CLLocation.init(latitude: coordinate!.latitude, longitude: coordinate!.longitude))
                    }
                }
                
                self.flatPanelView.isUserInteractionEnabled = true
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configurationHandler(textField: UITextField!) {
        if textField != nil {
            self.pickerTextField = textField!
            self.pickerTextField.placeholder = "Enter location as city, street"
        }
    }
    
    private func addPointAnnotation(location: CLLocation) {
        // Center map view
        let locationCenter = location
        let locationRegion = MKCoordinateRegion(center:  locationCenter.coordinate,
                                                span:    MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        
        self.mapView.setRegion(locationRegion, animated: true)

        // Add new point annotation
        guard let settingsPointAnnotation = self.model.settingsPointAnnotation else {
            let locationPointAnnotation = MKPointAnnotation()
            locationPointAnnotation.coordinate = location.coordinate
            locationPointAnnotation.title = "User current location"
            self.mapView.addAnnotation(locationPointAnnotation)
            
            self.model.settingsPointAnnotation = locationPointAnnotation

            return
        }
        
        // Move created point annotation
        settingsPointAnnotation.title = "Geofence location"
        UIView.animate(withDuration: 0.5, animations: {
            settingsPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        })
    }
    
    
    // MARK: - Actions
    @IBAction func settingsBarButtonItemTap(_ sender: Any) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        guard !UserDefaults.standard.bool(forKey: locationAuthStatusKey) else {
            self.isAlertViewShow = false
            return
        }

        guard self.flatPanelViewTopConstraint.constant == self.flatPanelHide else { return }
        
        // Show flat panel
        self.flatPanel(hide: false)
    }
    
    // Settings buttons
    @IBAction func settingsCurrentLocationButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Set point annotation to current user location
        if let userCurrentLocation = self.model.settingsUserCurrentLocation {
            self.addPointAnnotation(location: userCurrentLocation)
        }
    }
    
    @IBAction func settingsEnteringGeofenceButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        self.showAlertViewWithTextField()
        self.flatPanelView.isUserInteractionEnabled = false
    }
    
    @IBAction func settingsWiFiButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        if let networkNames = SSID.currentSSIDs() {
            print("MainShowViewController: function: \(#function), line: \(#line): networkNames = \(networkNames)")

            self.pickerViewDataSource = networkNames
            self.pickerTextField.becomeFirstResponder()
            
            if self.model.settingsWiFiValue == "XXX" {
                self.model.settingsWiFiIndex = 0
                self.model.settingsWiFiValue = networkNames[0]
                UserDefaults.standard.set(self.model.settingsWiFiValue, forKey: settingsWiFiKey)
            }
            
            else {
                self.model.settingsWiFiIndex = (self.pickerViewDataSource as! [String]).firstIndex(of: self.model.settingsWiFiValue) ?? 0
            }
            
            self.pickerView.selectRow(self.model.settingsWiFiIndex, inComponent: 0, animated: true)
            self.flatPanelView.isUserInteractionEnabled = false
            sender.isSelected = true
        }
    }
   
    @IBAction func settingsRadiusButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        self.pickerViewDataSource = Array(1...1000).compactMap({ $0 * 100 })
        self.pickerTextField.becomeFirstResponder()
        
        self.model.settingsRadiusValue = UserDefaults.standard.float(forKey: settingsRadiusKey)
        self.model.settingsRadiusIndex = (self.pickerViewDataSource as! [Int]).firstIndex(of: Int(self.model.settingsRadiusValue)) ?? 0
        
        self.pickerView.selectRow(self.model.settingsRadiusIndex, inComponent: 0, animated: true)
        self.flatPanelView.isUserInteractionEnabled = false
        sender.isSelected = true
    }
    
    @IBAction func settingsReadyButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Modify stored properties
        UserDefaults.standard.set(self.model.settingsRadiusValue, forKey: settingsRadiusKey)
        
        // Hide flat panel
        self.flatPanel(hide: true)
    }

    @IBAction func settingsCancelButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Hide flat panel without change stored properties
        self.flatPanel(hide: true)
    }

    @IBAction func settingsDeleteButtonTap(_ sender: UIButton) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Clean all stored properties
        self.model.clearAllProperties()
        
        // Hide flat panel
        self.flatPanel(hide: true)
    }
    
    // Picker view buttons
    @objc func onDoneButtonTapped(sender: UIBarButtonItem) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        if self.pickerTextField.isFirstResponder {
            self.pickerTextField.resignFirstResponder()
        }
        
        self.roundButtonsCollection.forEach({ $0.isSelected = false })
        self.flatPanelView.isUserInteractionEnabled = true
    }

    // Notification
    @objc func reachabilityChanged(note: Notification) {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.showAlertView(message: "Reachable via Wi-Fi")
        
        case .cellular:
            self.showAlertView(message: "Reachable via Cellular")

        case .none:
            self.showAlertView(message: "Network not reachable")
        }
    }
    
    // Map view
    @objc func mapViewTapped(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        self.addPointAnnotation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
}


// MARK: - MKMapViewDelegate
extension MainShowViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        let identifier = currentUserLocationKey
        
//        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "icon-geotification-delete")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            }
            
            else {
                annotationView?.annotation = annotation
            }
           
            return annotationView
//        }
        
//        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("MainShowViewController: function: \(#function), line: \(#line): run")

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
        print("MainShowViewController: function: \(#function), line: \(#line): run")

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
        print("MainShowViewController: function: \(#function), line: \(#line): run")

        // Modify stored properties
        if let valueInt = self.pickerViewDataSource[row] as? Int {
            self.model.settingsRadiusIndex = row
            self.model.settingsRadiusValue = Float(valueInt)
        }
        
        else if let valueString = self.pickerViewDataSource[row] as? String {
            self.model.settingsWiFiIndex = row
            self.model.settingsWiFiValue = valueString
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension MainShowViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.mapView.showsUserLocation = (status == .authorizedAlways)
        UserDefaults.standard.set(status == .denied, forKey: locationAuthStatusKey)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            
            self.mapView.setRegion(region, animated: true)
            
            // Set current user location
            self.model.settingsUserCurrentLocation = location
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center:       geotification.coordinate,
                                      radius:       geotification.radius,
                                      identifier:   geotification.identifier)

        region.notifyOnEntry = true
        region.notifyOnExit = true
     
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            self.showAlertView(title: "Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            self.showAlertView(title: "Warning", message: "Your geotification is saved but will only be activated once you grant Geofencing permission to access the device location")
        }
        
        let fenceRegion = region(with: geotification)
        self.locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            
            self.locationManager.stopMonitoring(for: circularRegion)
        }
    }
}
