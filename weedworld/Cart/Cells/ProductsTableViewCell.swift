//
//  ProductsTableViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 24/06/2023.
//

import UIKit

class ProductsTableViewCell: UITableViewCell {
	
    @IBOutlet weak var cellView: UIView! {
        didSet {
            cellView.layer.backgroundColor = UIColor(red: 0.162, green: 0.162, blue: 0.162, alpha: 1).cgColor
            cellView.layer.cornerRadius = 15
            cellView.layer.borderWidth = 0.2
        }
    }
    @IBOutlet weak var cartName: UILabel!
	@IBOutlet weak var cartCategory: UILabel!
	@IBOutlet weak var CBDTHC: UILabel!
	@IBOutlet weak var gramme: UILabel!
	@IBOutlet weak var cartImage: UIImageView! {
		didSet {
			cartImage.layer.cornerRadius = 15
            cartImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		}
	}
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var vapButton: UIButton! {
        didSet {
            vapButton.contentHorizontalAlignment = .right
        }
    }
    var plusAction: (() -> Void)?
	var moinsAction: (() -> Void)?
	var removeAction: (() -> Void)?
	var quantity = 1 {
		didSet {
			quantityLabel.text = quantity.description
		}
	}
	
	@IBAction func xmarClick(_ sender: UIButton) {
		removeAction?()
	}
	
	@IBAction func plusClick(_ sender: UIButton) {
		plusAction?()
	}
	
	@IBAction func moinsClick(_ sender: UIButton) {
		moinsAction?()
	}
}
