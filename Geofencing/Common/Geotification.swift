//
//  Geotification.swift
//  Geofencing
//
//  Created by msm72 on 12/30/18.
//  Copyright © 2018 golos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Geotification: NSObject, Codable, MKAnnotation {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, radius, identifier, note
    }
    
    
    // MARK: - Properties
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String?
    
    var title: String? {
        if note == nil {
            return "No Note"
        }
        
        return note
    }
    
    var subtitle: String? {
        return "Radius: \(radius)m"
    }
    
    
    // MARK: - Class Initialization
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String? = nil) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        note = try values.decode(String.self, forKey: .note)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
    }
}

extension Geotification {
    public class func allGeotifications() -> [Geotification]? {
        guard let savedData = UserDefaults.standard.data(forKey: geotificationsDataKey) else { return nil }
        
        let decoder = JSONDecoder()
        
        if let savedGeotifications = try? decoder.decode(Array.self, from: savedData) as [Geotification] {
            return savedGeotifications
        }
        
        return []
    }
}
