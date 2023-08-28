//
//  CategorisBusinessCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 14/05/2023.
//

import UIKit

class CategorisBusinessCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var allLabel: UILabel!
	@IBOutlet weak var viewContent: UIView!
	@IBOutlet weak var categorieTitle: UILabel!
	@IBOutlet weak var categorieImage: UIImageView! {
		didSet {
			categorieImage.layer.cornerRadius = 12
		}
	}
}
