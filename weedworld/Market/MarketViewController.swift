//
//  MarketViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 13/06/2023.
//

import UIKit

class MarketViewController: UIViewController, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UIBarButtonItem!
	@IBOutlet weak var marketsCollectionView: UICollectionView!
	var storesArray: [LocalStore] = []
	var storesArrayFiltred: [LocalStore] = [] {
		didSet {
			marketsCollectionView.reloadData()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		Task {
			async let stores = getStores()
			storesArray = await stores
			storesArrayFiltred = await stores
		}
    }
	
	func getStores() async -> [LocalStore] {
		let stores = try? await FirebaseHelper.getFeaturedStores()
		guard let stores = stores else {
			showAlert(title: "Error", message: "An error has occured please try later.")
			return []
		}
		return stores
	}

	@IBAction func backBtnClick(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func searchButtonClick(_ sender: UIBarButtonItem) {		
		let storyBoard = UIStoryboard(name: "SearchProducts", bundle: nil)
		let searchVC = storyBoard.instantiateViewController(withIdentifier: "searchProducts") as! SearchProductsViewController
		self.navigationController?.pushViewController(searchVC, animated: false)
	}
}

extension MarketViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return storesArrayFiltred.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MarketCollectionViewCell
		
		let model = storesArrayFiltred[indexPath.item]
		
		cell.storeName.text = model.businessName
		cell.storeImage.kf.setImage(with: URL(string: model.photo ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
		cell.marketImage.kf.setImage(with: URL(string: model.coverPhoto ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let businessPage = BusinessPageViewController(nibName: "BusinessPageViewController", bundle: nil)
		businessPage.passedStore = storesArrayFiltred[indexPath.item]
		businessPage.modalTransitionStyle = .crossDissolve
		businessPage.modalPresentationStyle = .fullScreen
		present(businessPage, animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width - 100, height: collectionView.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	}
}
