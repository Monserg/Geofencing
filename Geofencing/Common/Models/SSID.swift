//
//  SSID.swift
//  Geofencing
//
//  Created by msm72 on 12/29/18.
//  Copyright © 2018 golos. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

public class SSID {
    class func currentSSIDs() -> [String]? {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        return interfaceNames.compactMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            
            return ssid
        }
    }
}
