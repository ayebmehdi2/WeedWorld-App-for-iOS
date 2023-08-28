//
//  OrderCell.swift
//  weedworld
//
//  Created by Mac on 21/7/2023.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var contentBox: UIView! {
        didSet {
            contentBox.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var deliveryStatus: UILabel!
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
