//
//  QRCodeViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 30/1/2023.
//

import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var popuView: UIView! {
        didSet {
            popuView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var qrCodeImage: UIImageView!
    var QRCodeString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = generateQRCode(from: QRCodeString)
        qrCodeImage.image = image
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
