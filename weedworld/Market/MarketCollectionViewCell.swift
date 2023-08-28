//
//  MarketCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 13/06/2023.
//

import UIKit

class MarketCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var marketImage: UIImageView! {
		didSet {
			marketImage.layer.cornerRadius = 6
		}
	}
	@IBOutlet weak var storeImage: UIImageView! {
		didSet {
			storeImage.layer.cornerRadius = storeImage.frame.height / 2
		}
	}
	@IBOutlet weak var storeName: UILabel!
}
