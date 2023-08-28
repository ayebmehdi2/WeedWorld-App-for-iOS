//
//  SocialCollectionViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 28/05/2023.
//

import UIKit

class SocialCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var postLikes: UIButton!
	@IBOutlet weak var postText: UILabel!
	@IBOutlet weak var postImage: UIImageView! {
		didSet {
			postImage.layer.cornerRadius = 7
		}
	}
	@IBOutlet weak var postComments: UIButton!
}
