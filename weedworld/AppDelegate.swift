//
//  AppDelegate.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/1/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
		
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        FirebaseApp.configure()
        
        if let currentUser = Auth.auth().currentUser {
            FirebaseHelper.getUserByUID(uid: currentUser.uid, completion: { user in
                if let user = user {
                    GlobalVar.user = user
                }
            })
        }
        
        // Location Manager
		DispatchQueue.global().async { [self] in
			locationManager.delegate = self
			locationManager.requestWhenInUseAuthorization()
			if CLLocationManager.locationServicesEnabled() {
				locationManager.distanceFilter = 100
				locationManager.desiredAccuracy = kCLLocationAccuracyBest
				locationManager.startUpdatingLocation()
			}
		}
		
		// Get user Store
		Task {
			await getUserStore()
		}
		
		// Google maps
		GMSServices.provideAPIKey("AIzaSyDN-zZ7-kyqLpLyua4vqmnnE3xOHtl9C70")
		GMSPlacesClient.provideAPIKey("AIzaSyDN-zZ7-kyqLpLyua4vqmnnE3xOHtl9C70")
		
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation) { [weak self] (placemarks, error) in
                if error == nil {
                    if let firstLocation = placemarks?[0],
                       let cityName = firstLocation.locality,
                       let countryName = firstLocation.administrativeArea { // get the city name
                        GlobalVar.userLocation = cityName + ", " + countryName
                        self?.locationManager.stopUpdatingLocation()
                    }
                }
            }
        }
		if let location = locations.first {
			GlobalVar.userLocationCoordinate = location.coordinate
		}
    }
	
	func getUserStore() async {
		let stores = try? await FirebaseHelper.getStoreByUserId()
		guard let stores = stores else { return }
		GlobalVar.userStore = stores.first
	}

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

