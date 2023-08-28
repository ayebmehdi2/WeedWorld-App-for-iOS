//
//  ItemsBusinessTableViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 14/05/2023.
//

import UIKit

class ItemsBusinessTableViewCell: UITableViewCell {
	
	@IBOutlet weak var brandName: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var THCCBD: UILabel!
	@IBOutlet weak var itemImage: UIImageView! {
		didSet {
			itemImage.layer.cornerRadius = itemImage.frame.height / 2
		}
	}
	@IBOutlet weak var grammeLabel: UILabel!
	@IBOutlet weak var priceView: UIView! {
		didSet {
			priceView.layer.cornerRadius = 6
			priceView.layer.borderWidth = 1
			priceView.layer.borderColor = UIColor.lightGray.cgColor
		}
	}
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var categoryName: UILabel!
	@IBOutlet weak var discountPrice: UILabel!
}
