//
//  NearbyViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import UIKit
import Kingfisher
import CoreLocation

class NearbyViewController: UIViewController {
	
	@IBOutlet weak var nearbyCollectionVew: UICollectionView!
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	var usersArray: [User] = [] {
		didSet {
			nearbyCollectionVew.reloadData()
		}
	}
	var userLocationArray: [UserLocation] = []
	var selectedIndex = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		Task {
			await getOnlineUsers()
			await updateLocation()
		}
	}
	
	func getOnlineUsers() async {
		if let userLocation = GlobalVar.userLocationCoordinate {
			showActivityIndicator(view: view, activityIndicator: activityIndicator)
			
			do {
				let users = try await FirebaseHelper.getNearbyUsers(userLat: userLocation.latitude, userLong: userLocation.longitude, radius: 50)
				
				guard let users = users else { return }
				userLocationArray = users
				
				for user in users {
					FirebaseHelper.getUserByUID(uid: user.userId ?? "", completion: { user in
						guard let user = user else { return }
						self.usersArray.append(user)
					})
				}
				stopActivityIndicator(activityIndicator: activityIndicator)
				
			} catch let errr {
				print("Error fetching data: \(errr)")
			}
		}
	}
	
	func updateLocation() async {
		if let userLocation = GlobalVar.userLocationCoordinate {
			do {
				let updateRes = try await FirebaseHelper.updateNearbyPosition(userLat: userLocation.latitude, userLong: userLocation.longitude)
				
				if !updateRes {
					showAlert(title: "Alert", message: "An error has occured while updating position.")
				}
				
			} catch let errr {
				print("Error fetching data: \(errr)")
				showAlert(title: "Alert", message: "An error has occured while updating position.")
			}
		}
	}
	
	@IBAction func menuClick(_ sender: UIBarButtonItem) {
		showSideMenu()
	}
}

extension NearbyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return usersArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NearbyCollectionViewCell
		
		cell.contentView.layer.cornerRadius = 10
		cell.contentView.clipsToBounds = true
		
		// Data
		let model = usersArray[indexPath.row]
		let modelLocation = userLocationArray[indexPath.item]
		cell.userImage.kf.setImage(with: URL(string: model.profilePhoto ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
		cell.userName.text = model.username.capitalized
		cell.userGender.image = model.gender == "Male" ? UIImage(named: "male blue") : UIImage(named: "female")
		
		if let userLocation = GlobalVar.userLocationCoordinate, let lat2 = modelLocation.lat, let long2 = modelLocation.lng {
			let distance = getDistanceBetweenLocation(userLocation.latitude, userLocation.longitude, lat2, long2)
			cell.distanceLabel.text = String(format: "%.2f", distance / 1000) + " Km"
		}
		
		return cell
	}
	
	func getDistanceBetweenLocation(_ lat1: Double, _ long1: Double, _ lat2: Double, _ long2: Double) -> CLLocationDistance {
		let location1 = CLLocation(latitude: lat1, longitude: long1)
		let location2 = CLLocation(latitude: lat2, longitude: long2)
		
		return location1.distance(from: location2)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedIndex = indexPath.item
		performSegue(withIdentifier: "toDetailsFromNearby", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toDetailsFromNearby" {
			if let detailsVC = segue.destination as? DetailsChatViewController {
				detailsVC.passedUser = usersArray[selectedIndex]
			}
		}
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let padding: CGFloat = 35 // Left and Right UIEdgeInsets + (minimumInteritemSpacingForSectionAt * nb cells)
		let collectionViewSize = collectionView.bounds.width - padding
		let width = collectionViewSize / 3
		return CGSize(width: width, height: width + padding + 30)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	}
}
