//
//  SearchProductsViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 03/07/2023.
//

import UIKit

class SearchProductsViewController: UIViewController, UISearchBarDelegate {

	@IBOutlet weak var businessesTableView: UITableView!
	@IBOutlet weak var productsTableView: UITableView!
	@IBOutlet weak var businessBtn: UIButton!
	@IBOutlet weak var productsBtn: UIButton!
	@IBOutlet weak var lineView: UIView!
	@IBOutlet var lineViewCenterXConstraint: NSLayoutConstraint!
	var lineViewCenterXRightConstraint: NSLayoutConstraint!
	var productsArray: [Product] = [] {
		didSet {
			productsTableView.reloadData()
			stopActivityIndicator(activityIndicator: activityIndicator)
		}
	}
	var storesArray: [LocalStore] = [] {
		didSet {
			businessesTableView.reloadData()
			stopActivityIndicator(activityIndicator: activityIndicator)
		}
	}
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	let searchController = UISearchController()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setupView()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		productsBtn.isSelected = true
		searchController.searchBar.delegate = self
		searchController.hidesNavigationBarDuringPresentation = false
		present(searchController, animated: true, completion: nil)
	}
	
	func setupView() {
		businessBtn.setTitleColor(.systemGray, for: .normal)
		businessBtn.setTitleColor(.label, for: .selected)
		productsBtn.setTitleColor(.systemGray, for: .normal)
		productsBtn.setTitleColor(.label, for: .selected)
		
		lineViewCenterXRightConstraint = lineView.centerXAnchor.constraint(equalTo: businessBtn.centerXAnchor)
	}
	
	func getProductsSearched(name: String) async -> [Product] {
		let products = try? await FirebaseHelper.getItemsByName(name: name.lowercased())
		guard let products = products else {
			showAlert(title: "Error", message: "An error has occured please try later.")
			return []
		}
		return products
	}
	
	func getStoresSearched(businessName: String) async -> [LocalStore] {
		let stores = try? await FirebaseHelper.getStoresByBusinessName(businessName: businessName.lowercased())
		guard let stores = stores else {
			showAlert(title: "Error", message: "An error has occured please try later.")
			return []
		}
		return stores
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			storesArray.removeAll()
			productsArray.removeAll()
			return
		}
		showActivityIndicator(view: view, activityIndicator: activityIndicator)
		if businessBtn.isSelected {
			Task {
				async let stores = getStoresSearched(businessName: searchText)
				storesArray = await stores
			}
		} else {
			Task {
				async let products = getProductsSearched(name: searchText)
				productsArray = await products
			}
		}
	}
	
	@IBAction func businessClick(_ sender: UIButton) {
		lineViewCenterXConstraint.isActive = false
		lineViewCenterXRightConstraint.isActive = true
		businessBtn.isSelected = true
		productsBtn.isSelected = false
		businessesTableView.isHidden = false
		productsTableView.isHidden = true
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
		})
	}
	
	@IBAction func productsClick(_ sender: UIButton) {
		lineViewCenterXRightConstraint.isActive = false
		lineViewCenterXConstraint.isActive = true
		businessBtn.isSelected = false
		productsBtn.isSelected = true
		businessesTableView.isHidden = true
		productsTableView.isHidden = false
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
		})
	}
}

extension SearchProductsViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableView == productsTableView ? productsArray.count : storesArray.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == productsTableView {
			let cellProducts = tableView.dequeueReusableCell(withIdentifier: "cellProducts", for: indexPath) as! ProductsSearchTableViewCell
			
			let model = productsArray[indexPath.row]
			
			cellProducts.brandName.text = model.brand
			cellProducts.name.text = model.name
			cellProducts.categoryName.text = model.category
			cellProducts.THCCBD.text = "THC: \(model.thc ?? 0)% | CBD: \(model.cbd ?? 0)%"
			let attributeString = NSMutableAttributedString(string: "$" + (model.price?.description ?? ""))
			
			// Add strikethrough style
			attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
			
			// Add red color to the strikethrough style
			attributeString.addAttribute(.strikethroughColor, value: UIColor.red, range: NSRange(location: 0, length: attributeString.length))
			
			cellProducts.price.attributedText = attributeString
			cellProducts.grammeLabel.text = Int(model.weight ?? 0).description + "g"
			cellProducts.discountPrice.text = "$" + (model.discountPrice?.description ?? "-")
			cellProducts.productImage.kf.setImage(with: URL(string: model.images?.first ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
			
			return cellProducts
		}
		else {
			let cellBusinesses = tableView.dequeueReusableCell(withIdentifier: "cellBusinesses", for: indexPath) as! BusinessesSearchTableViewCell
			
			let model = storesArray[indexPath.row]
			
			cellBusinesses.businessType.text = model.businessType
			cellBusinesses.storeName.text = model.businessName
			cellBusinesses.businessImage.kf.setImage(with: URL(string: model.photo ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
			
			return cellBusinesses
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == productsTableView {
			let storyBoard = UIStoryboard(name: "ItemDetails", bundle: nil)
			let itemVC = storyBoard.instantiateViewController(withIdentifier: "itemDetailsVC") as! UINavigationController
			let child = itemVC.children.first as! ItemDetailsViewController
			child.passedItem = productsArray[indexPath.row]
			searchController.dismiss(animated: true)
			present(itemVC, animated: true)
		}
		else {
			let businessPage = BusinessPageViewController(nibName: "BusinessPageViewController", bundle: nil)
			businessPage.passedStore = storesArray[indexPath.item]
			businessPage.modalTransitionStyle = .crossDissolve
			businessPage.modalPresentationStyle = .fullScreen
			searchController.dismiss(animated: true)
			present(businessPage, animated: true)
		}
	}
}
