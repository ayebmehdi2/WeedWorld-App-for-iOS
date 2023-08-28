//
//  CustomPageViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/1/2023.
//

import UIKit

protocol CustomPageDelegate: AnyObject  {
    func pageChangeTo(index: Int)
}

class CustomPageViewController: UIPageViewController {

    var individualPageViewControllerList = [UIViewController]()
    weak var customDelegate: CustomPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        // self.dataSource = self
        
        individualPageViewControllerList = [
            PageDetailsViewController.getInstance(index: 0),
            PageDetailsViewController.getInstance(index: 1),
            PageDetailsViewController.getInstance(index: 2)
        ]
        setViewControllers([individualPageViewControllerList[0]], direction: .forward, animated: true)
    }
}

extension CustomPageViewController: UIPageViewControllerDelegate {
    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//
//        let indexOfCurrentPageVC = individualPageViewControllerList.firstIndex(of: viewController)!
//
//        if indexOfCurrentPageVC == 0 {
//            return individualPageViewControllerList[indexOfCurrentPageVC]
//        }
//        else {
//            return individualPageViewControllerList[indexOfCurrentPageVC - 1]
//        }
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//        let indexOfCurrentPageVC = individualPageViewControllerList.firstIndex(of: viewController)!
//
//        if indexOfCurrentPageVC == individualPageViewControllerList.count - 1 {
//            return nil
//        }
//        else {
//            return individualPageViewControllerList[indexOfCurrentPageVC + 1]
//        }
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndexPageVC = pageViewController.viewControllers?.first as? PageDetailsViewController {
            guard let index = individualPageViewControllerList.firstIndex(of: currentIndexPageVC) else { return }
            customDelegate?.pageChangeTo(index: index)
        }
    }
}
