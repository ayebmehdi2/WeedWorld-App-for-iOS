//
//  ImageViewerViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/3/2023.
//

import UIKit

class ImageViewerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var postImage: UIImageView!
    var passedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postImage.image = passedImage
        setupScrollView()
    }
    
    func setupScrollView() {
        myScrollView.minimumZoomScale = 1
        myScrollView.maximumZoomScale = 3.5
        myScrollView.delegate = self
        addGesture()
    }
    
    func addGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        myScrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        if myScrollView.zoomScale > myScrollView.minimumZoomScale {
            myScrollView.setZoomScale(myScrollView.minimumZoomScale, animated: true)
        } else {
            myScrollView.zoom(to: zoomRectForScale(scale: myScrollView.maximumZoomScale, center: gesture.location(in: gesture.view)), animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = postImage.frame.size.height / scale
        zoomRect.size.width  = postImage.frame.size.width  / scale
        let newCenter = myScrollView.convert(center, to: postImage)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return postImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = postImage.image {
                let ratioW = postImage.frame.width / image.size.width
                let ratioH = postImage.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth * scrollView.zoomScale > postImage.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - postImage.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight * scrollView.zoomScale > postImage.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - postImage.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}
