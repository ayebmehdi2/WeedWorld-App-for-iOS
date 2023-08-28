//
//  NearbyCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 03/04/2023.
//

import UIKit

class NearbyCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var userGender: UIImageView!
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var userImage: UIImageView! {
		didSet {
			userImage.layer.cornerRadius = userImage.frame.height / 2
		}
	}
}
