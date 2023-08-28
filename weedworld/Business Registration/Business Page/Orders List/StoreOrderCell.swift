//
//  StoreOrderCell.swift
//  weedworld
//
//  Created by Mac on 22/7/2023.
//

import UIKit

class StoreOrderCell: UITableViewCell {

    @IBOutlet weak var validateButton: UIButton! {
        didSet {
            validateButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var orderStatusLAbel: UILabel!
    @IBOutlet weak var orderIDLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
