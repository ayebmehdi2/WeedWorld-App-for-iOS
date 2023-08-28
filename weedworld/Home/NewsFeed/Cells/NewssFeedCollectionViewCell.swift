//
//  NewssFeedCollectionViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 2/2/2023.
//

import UIKit

class NewssFeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var newsImage: UIImageView! {
        didSet {
            newsImage.layer.cornerRadius = 7
        }
    }
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var commentsNbr: UIButton!
    @IBOutlet weak var likesNbr: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
