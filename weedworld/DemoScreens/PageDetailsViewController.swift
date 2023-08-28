//
//  PageDetailsViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/1/2023.
//

import UIKit

class PageDetailsViewController: UIViewController {

    @IBOutlet weak var imageDetails: UIImageView!
    var images = ["FirstScreen", "SecondScreen", "ThirdScreen"]
    @IBOutlet weak var titleText: UILabel!
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setTitleText()
    }
    
    func setupUI() {
        imageDetails.image = UIImage(named: images[index])
        titleText.font = UIFont(name: "Poppins-SemiBold", size: 36)!
    }
    
    func setTitleText() {
        switch index {
            
        case 0:
            titleText.text = "Satisfy your cannabis curiosity"
            titleText.textColor = .black
            
        case 1:
            titleText.text = "Share your stories & experiences"
            titleText.textColor = .customLightPink
            
        case 2:
            titleText.text = "Connect with like-minded people"
            titleText.textColor = .customRed
            
        default:
            break
        }
    }
    
    static func getInstance(index: Int) -> PageDetailsViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PageDetailsViewController") as! PageDetailsViewController
        vc.index = index
        return vc
    }
}
