//
//  AddEditItemCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 30/05/2023.
//

import UIKit

class AddEditItemCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var itemImage: UIImageView! {
		didSet {
			itemImage.layer.cornerRadius = itemImage.frame.height / 2
		}
	}
	@IBOutlet weak var plusImage: UIImageView!
}
