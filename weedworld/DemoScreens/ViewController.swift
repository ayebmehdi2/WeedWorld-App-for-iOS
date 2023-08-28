//
//  ViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/1/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var skipBtn: UIButton!
    var index: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CustomPageViewController {
            destination.customDelegate = self
        }
    }
    
    @IBAction func skipClick(_ sender: UIButton) {
        let childVC = children.first as! CustomPageViewController
        
        if index == childVC.individualPageViewControllerList.count {
            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! ParentViewController
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            present(loginVC, animated: true)
        }
        
        else {
            childVC.setViewControllers([childVC.individualPageViewControllerList[index]], direction: .forward, animated: true)
            if index == 1 {
                skipBtn.setTitleColor(.black, for: .normal)
                skipBtn.tintColor = .black
            }
            else if index == 2 {
                skipBtn.setTitleColor(.white, for: .normal)
                skipBtn.tintColor = .white
            }
            index += 1
            progressView.progress = Float(index) / 3
        }
    }
}

extension ViewController: CustomPageDelegate {
    
    func pageChangeTo(index: Int) {
        
        switch index {
            
        case 0:
            progressView.progress = 1 / 3
            
        case 1:
            progressView.progress = 2 / 3
            
        case 2:
            progressView.progress = 1
            
        default:
            break
        }
    }
}
