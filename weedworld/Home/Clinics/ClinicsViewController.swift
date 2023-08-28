//
//  ClinicsViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import UIKit
import GoogleMaps

class ClinicsViewController: UIViewController {
	
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var detailsContainerView: UIView!
	let imagesArray = ["recretional", "medical", "delivery", "clinic", "smoke", "all"]
	let titlesArray = ["Recretional", "Medical store", "Delivery service", "Clinic", "Smoke Shop", "All"]
	@IBOutlet weak var clinicsTableView: UITableView!
	var storesArray: [LocalStore] = [] {
		didSet {
			clinicsTableView.reloadData()
		}
	}
	
	@IBOutlet weak var searchTF: UITextField! {
		didSet {
			searchTF.layer.cornerRadius = searchTF.frame.height / 2
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
        setupI()
		setupMapView()
		Task {
			await getNearbyStores()
		}
    }
	
	func setupI() {
		searchTF.addLeftImage(imageName: "search")
	}
	
	func setupMapView() {		
		// Creates a marker in the center of the map.
		if let coordinate = GlobalVar.userLocationCoordinate {
			let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
			mapView.camera = camera
			mapView.isMyLocationEnabled = true
		}
	}
	
	func getNearbyStores() async {
		if let lat = GlobalVar.userLocationCoordinate?.latitude, let long = GlobalVar.userLocationCoordinate?.longitude {
			do {
				let stores = try await FirebaseHelper.getNearbyStores(userLat: lat, userLong: long, radius: 50)
				
				storesArray.append(contentsOf: stores)
				showLocationsOnMap(storesArray: storesArray)
				
			} catch let errr {
				print("Error fetching data: \(errr)")
			}
		}
	}
	
	func showLocationsOnMap(storesArray: [LocalStore]) {
		for store in storesArray {
			if let latitude = store.lat, let longitute = store.lng {
				let marker = GMSMarker()
				marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitute)
				marker.title = store.businessName
				marker.snippet = store.businessType
				
				if let image = store.photo {
					let url = URL(string: image)
					let placeholderImage = UIImage(named: "placeholder")
					let imageView = UIImageView()
					imageView.kf.setImage(with: url, placeholder: placeholderImage) { result in
						switch result {
							
						case .success(let image):
							let imageResized = self.resizeImage(image: image.image, newWidth: 40)
							marker.icon = imageResized
							marker.map = self.mapView
							
						case .failure(let error):
							print("Error downloading image: \(error)")
						}
					}
				}
				marker.map = mapView
			}
		}
	}
	
	func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
		let scale = newWidth / image.size.width
		let newHeight = image.size.height * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	@IBAction func menuClick(_ sender: UIButton) {
		showSideMenu()
	}
}

extension ClinicsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imagesArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ClinicsCollectionViewCell
		
		cell.imageCell.image = UIImage(named: imagesArray[indexPath.row])
		cell.titleCell.text = titlesArray[indexPath.row]
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: 80)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 25
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .zero
	}
}

extension ClinicsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return storesArray.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellTV", for: indexPath)
		 as! ClincsTableViewCell
		
		let model = storesArray[indexPath.row]
		cell.titleCell.text = model.businessName
		cell.subTitleCell.text = model.businessType
		
		if let image = model.photo {
			cell.imageCell.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"), options: [])
		}
		
		if let userLocation = GlobalVar.userLocationCoordinate, let lat2 = model.lat, let long2 = model.lng {
			let distance = getDistanceBetweenLocation(userLocation.latitude, userLocation.longitude, lat2, long2)
			cell.meterCell.text = String(format: "%.2f", distance / 1000) + " Km"
		}
		
		return cell
	}
	
	func getDistanceBetweenLocation(_ lat1: Double, _ long1: Double, _ lat2: Double, _ long2: Double) -> CLLocationDistance {
		let location1 = CLLocation(latitude: lat1, longitude: long1)
		let location2 = CLLocation(latitude: lat2, longitude: long2)
		
		return location1.distance(from: location2)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let detailsVC = children.first! as! DetailsClinicViewController
		let model = storesArray[indexPath.row]
		detailsVC.passedStore = model
		if let userLocation = GlobalVar.userLocationCoordinate, let lat2 = model.lat, let long2 = model.lng {
			let distance = getDistanceBetweenLocation(userLocation.latitude, userLocation.longitude, lat2, long2)
			detailsVC.distance = String(format: "%.2f", distance / 1000) + " Km"
			getLocation(lat2, long2, completion: { succes, adress in
				if succes {
					detailsVC.location = adress
					detailsVC.fillData()
					self.view.bringSubviewToFront(self.detailsContainerView)
				}
			})
		}
	}
	
	func getLocation(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, completion: @escaping (_ succes: Bool, _ adress: String) -> Void) {
		let geocoder = CLGeocoder()
		let location = CLLocation(latitude: latitude, longitude: longitude)
		
		geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
			if let error = error {
				print("Geocoding failed with error: \(error.localizedDescription)")
				completion(false, "")
			}
			
			if let placemark = placemarks?.first {
				let adress = "\(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""),  \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
				completion(true, adress)
			} else {
				print("No placemarks found.")
				completion(false, "")
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
}
