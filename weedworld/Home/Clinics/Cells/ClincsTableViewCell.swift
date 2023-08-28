//
//  ClincsTableViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 04/04/2023.
//

import UIKit

class ClincsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var imageCell: UIImageView! {
		didSet {
			imageCell.layer.cornerRadius = imageCell.frame.height / 2
		}
	}
	@IBOutlet weak var meterCell: UILabel!
	@IBOutlet weak var subTitleCell: UILabel!
	@IBOutlet weak var titleCell: UILabel!
}
