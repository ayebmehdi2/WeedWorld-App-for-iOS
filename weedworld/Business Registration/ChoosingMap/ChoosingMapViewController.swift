//
//  ChoosingMapViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 16/04/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol ChoosingMapViewDelegate: AnyObject {
	func passLocationData(streetName: String, city: String, coordinate: CLLocationCoordinate2D)
}

class ChoosingMapViewController: UIViewController {

	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var confirmBtn: UIButton! {
		didSet {
			confirmBtn.layer.cornerRadius = 5
			confirmBtn.layer.borderWidth = 0.5
			confirmBtn.layer.borderColor = UIColor.systemGray.cgColor
		}
	}
	weak var delegate: ChoosingMapViewDelegate?
	let marker = GMSMarker()
	var streetName: String?
	var city: String?
	var coordinate: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		title = "Local Store"
		setupMapView()
    }
	
	func setupMapView() {
		// Creates a marker in the center of the map.
		if let coordinate = GlobalVar.userLocationCoordinate {
			let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 12.0)
			
			// MapView
			mapView.camera = camera
			mapView.isMyLocationEnabled = true
			mapView.delegate = self
			
			// Marker
			marker.position = coordinate
			marker.appearAnimation = .pop
			marker.isDraggable = true
			marker.map = mapView
		}
	}
	
	@IBAction func confirmClick(_ sender: UIButton) {
		guard let streetName = streetName, let city = city, let coordinate = coordinate else { return }
		navigationController?.popViewController(animated: true)
		delegate?.passLocationData(streetName: streetName, city: city, coordinate: coordinate)
	}
}

extension ChoosingMapViewController: GMSMapViewDelegate {
	
	func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
		updateLocationoordinates(coordinates: position.target)
	}
		
	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		let centerCoordinate = position.target
		let geoCoder = GMSGeocoder()
		
		geoCoder.reverseGeocodeCoordinate(centerCoordinate, completionHandler: { response, error in
			
			if let error = error {
				print("Error getting location name: \(error.localizedDescription)")
				
			} else if let result = response?.firstResult() {
				
				let fullLocationName = result.lines?.joined(separator: ", ") ?? ""
				print("Full location name: ", fullLocationName)
				self.streetName = result.thoroughfare
				self.city = "\(result.locality ?? ""), \(result.country ?? ""), \(result.postalCode ?? "")"
				self.coordinate = centerCoordinate
			}
		})
	}
	
	func updateLocationoordinates(coordinates: CLLocationCoordinate2D) {
		CATransaction.begin()
		CATransaction.setAnimationDuration(0)
		marker.position = coordinates
		CATransaction.commit()
	}
}
