//
//  DetailsClinicViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 13/04/2023.
//

import UIKit

class DetailsClinicViewController: UIViewController {

	@IBOutlet weak var detailsClinicImage: UIImageView! {
		didSet {
			detailsClinicImage.layer.cornerRadius = detailsClinicImage.frame.height / 2
		}
	}
	@IBOutlet weak var lineView: UIView! {
		didSet {
			lineView.layer.cornerRadius = lineView.frame.height / 2
		}
	}
	@IBOutlet weak var detailsMeter: UILabel!
	@IBOutlet weak var detailsClinicType: UILabel!
	@IBOutlet weak var detailsClinicName: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var websiteLabel: UILabel!
	@IBOutlet weak var phoneLabel: UILabel!
	@IBOutlet weak var imagesCollectionView: UICollectionView!
	var imagesArray: [String] = ["clinic1", "clinic2", "clinic3", "clinic4"]
	var distance = ""
	var location = ""
	var passedStore: LocalStore?
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func fillData() {
		if let image = passedStore?.photo {
			detailsClinicImage.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"), options: [])
		}
		detailsClinicType.text = passedStore?.businessType
		detailsClinicName.text = passedStore?.businessName
		emailLabel.text = passedStore?.emailAddress
		websiteLabel.text = passedStore?.website
		phoneLabel.text = passedStore?.phone
		detailsMeter.text = distance
		locationLabel.text = location
	}
	
	@IBAction func backBtnClick(_ sender: UIButton) {
		let parentVC = parent as! ClinicsViewController
		parentVC.view.sendSubviewToBack(parentVC.detailsContainerView)
	}
}

extension DetailsClinicViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imagesArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! imagesCollectionViewCell
		
		cell.cellImage.image = UIImage(named: imagesArray[indexPath.item])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 50
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 75, height: 75)
	}
}
