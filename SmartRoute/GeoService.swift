//
//  GeoService.swift
//  SmartRoute
//
//  Created by zz on 08.02.2022.
//  Copyright © 2022 Vadim Vitkovskiy. All rights reserved.
//


import Foundation
import CoreLocation

class CoordinateService {
    static let shared = CoordinateService()
    
    func findCoordinate(placeSearch: String, completionHandler: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error : Error?) -> Void) {
        let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(placeSearch) { (place, error) in
            completionHandler(place?.first?.location?.coordinate, error)
        }
    }
}
