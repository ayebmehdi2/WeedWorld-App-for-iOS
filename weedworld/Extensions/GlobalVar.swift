//
//  GlobalVar.swift
//  weedworld
//
//  Created by Fares Ben amor on 1/2/2023.
//

import Foundation
import UIKit
import CoreLocation

struct GlobalVar {
    static var user: User?
    static var userLocation: String?
	static var userLocationCoordinate: CLLocationCoordinate2D?
	static var userStore: LocalStore?
}
