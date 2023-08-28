//
//  BusinessesSearchTableViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 04/07/2023.
//

import UIKit

class BusinessesSearchTableViewCell: UITableViewCell {

	@IBOutlet weak var storeName: UILabel!
	@IBOutlet weak var businessType: UILabel!
	@IBOutlet weak var businessImage: UIImageView! {
		didSet {
			businessImage.layer.cornerRadius = businessImage.frame.height / 2
		}
	}
}
