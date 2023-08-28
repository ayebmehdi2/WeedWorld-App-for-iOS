//
//  ImagesItemViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 31/05/2023.
//

import UIKit
import Kingfisher

class ImagesItemViewController: UIViewController {

	@IBOutlet weak var imagesCollectionView: UICollectionView!
	var imagesArray: [String] = []
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	@IBAction func backClick(_ sender: Any) {
		dismiss(animated: true)
	}
}

extension ImagesItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imagesArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! imagesItemsCollectionViewCell
		
		cell.imagesItems.kf.setImage(with: URL(string: imagesArray[indexPath.item]), placeholder: UIImage(named: "placeholder"), options: [])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .zero
	}
}
