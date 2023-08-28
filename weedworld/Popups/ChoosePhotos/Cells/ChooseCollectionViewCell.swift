//
//  ChooseCollectionViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 5/2/2023.
//

import UIKit

class ChooseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentImage: UIImageView! {
        didSet {
            contentImage.layer.cornerRadius = contentImage.frame.height / 2
        }
    }
    @IBOutlet weak var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//              UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
//                self.transform = self.transform.scaledBy(x: 0.95, y: 0.95)
//                })
//            }
//            else {
//                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
//                self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
//                })
//            }
//        }
//    }
}
