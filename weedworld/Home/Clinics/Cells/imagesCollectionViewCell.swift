//
//  imagesCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 13/04/2023.
//

import UIKit

class imagesCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var cellImage: UIImageView! {
		didSet {
			cellImage.layer.cornerRadius = 5
		}
	}
}
