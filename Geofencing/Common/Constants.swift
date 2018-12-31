//
//  Constants.swift
//  Geofencing
//
//  Created by msm72 on 12/29/18.
//  Copyright © 2018 golos. All rights reserved.
//

import Foundation

enum ActionType {
    case none
    case settings
    case geofence
}

let settingsKey                 =   "SettingsKey"
let locationAuthStatusKey       =   "LocationAuthorizationStatusKey"
let currentUserLocationKey      =   "CurrentUserLocationKey"

//let settingsWiFiKey             =   "SettingsWiFiValueKey"
//let settingsRadiusKey           =   "SettingsRadiusValueKey"
//let geotificationsDataKey       =   "GeotificationsDataKey"


let latitudeDelta   =   20.0
let longitudeDelta  =   20.0
