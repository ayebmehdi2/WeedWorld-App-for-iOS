//
//  CardsViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 12/06/2023.
//

import UIKit

class CardsViewController: UIViewController {

	@IBOutlet weak var emptyLabel: UILabel!
	@IBOutlet weak var cartsTableView: UITableView!
	let userDef = UserDefaults.standard
	var groupedProducts: [String?: Any] = [:] {
		didSet {
			cartsTableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setupTitleView()
		fillData()
    }
	
	func fillData() {
		if let products = userDef.data(forKey: "products") {
			do {
				let productsDecoded = try JSONDecoder().decode([Product].self, from: products)
								
				// Grouping products by storeId
				groupedProducts = Dictionary(grouping: productsDecoded, by: { $0.storeId })
				
				if productsDecoded.isEmpty {
					cartsTableView.isHidden = true
					emptyLabel.isHidden = false
				}
			} catch let err {
				showAlert(title: "Error", message: "An error has occured, please try later.")
				print("Error decoding ", err.localizedDescription)
			}
		} else {
			emptyLabel.isHidden = false
			cartsTableView.isHidden = true
		}
	}
	
	func setupTitleView() {
		let contentView = UIView()
		let imageView = UIImageView()
		let rectangleImage = UIImageView()
		
		// ContentView
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
		contentView.addSubview(rectangleImage)
		
		// ImageView
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(named: "cart")
		imageView.contentMode = .scaleAspectFill
		
		// RectangleView
		rectangleImage.translatesAutoresizingMaskIntoConstraints = false
		rectangleImage.image = UIImage(named: "rectangle")
		
		NSLayoutConstraint.activate([
			// ContentView
			contentView.widthAnchor.constraint(equalToConstant: 27),
			contentView.heightAnchor.constraint(equalToConstant: 36),
			
			// Imageview
			imageView.widthAnchor.constraint(equalToConstant: 27),
			imageView.heightAnchor.constraint(equalToConstant: 26),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			// RectangleImageView
			rectangleImage.widthAnchor.constraint(equalToConstant: 27),
			rectangleImage.heightAnchor.constraint(equalToConstant: 4),
			rectangleImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			rectangleImage.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5)
		])
		navigationItem.titleView = contentView
	}
	
	func getStore(storeId: String) async -> LocalStore? {
		let store = try? await FirebaseHelper.getStoreByStoreId(storeId: storeId)
		guard let store = store else { return nil }
		return store
	}
	
	@IBAction func backBtnClick(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
}

extension CardsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return groupedProducts.keys.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellNew", for: indexPath) as! CartTableViewCell
		
		let keysArray = Array(groupedProducts.keys)
		
		if let key = keysArray[indexPath.row] {
			Task {
				async let store = getStore(storeId: key)
				guard let store = await store else { return }
                cell.naviagtionAction = {
                    () -> Void in
                    guard let products = self.groupedProducts[key] as? [Product] else { return }
                    let checkout = CheckoutViewController()
                    checkout.products = products
                    checkout.store = store
                    self.setupNavBarStyle(storeName: store.businessName)
                    self.navigationController?.pushViewController(checkout, animated: true)
                }
				cell.shopName.text = store.businessName
				if let image = store.photo {
					cell.shopImage.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"), options: [])
				}
			}
			if let value = groupedProducts[key] as? [Product] {
				cell.productsArrayCell = value
				
				// Set total price
				var totalPrice: Double = 0
				
				for product in value {
					let price = product.discountPrice ?? 0
					let quantity = Double(product.quantity ?? 0)
					totalPrice += (price * quantity)
				}
				cell.totalPrice.text = "$" + String(format: "%.2f", totalPrice)
			}
		}
		cell.cardsVC = self
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var nbProducts: CGFloat = 1
		let keysArray = Array(groupedProducts.keys)
		
		if let key = keysArray[indexPath.row] {
			if let value = groupedProducts[key] as? [Product] {
				nbProducts = CGFloat(value.count)
			}
		}
		let imageStoreHeight: CGFloat = 50
		let imageCartHeight: CGFloat = 140 * nbProducts
		let topAndBottomCartPadding: CGFloat = 20
		let topAndBottomContentStackPadding: CGFloat = 20
		let contentStackPadding: CGFloat = 10
		let productStackTopAndBottomPadding: CGFloat = 20
		let otherStacksPadding: CGFloat = 30
		let totalLabelSHeight: CGFloat = 80
        let checkoutHeight: CGFloat = 75
		
		let total = imageStoreHeight + imageCartHeight + topAndBottomCartPadding + topAndBottomContentStackPadding + productStackTopAndBottomPadding + otherStacksPadding + totalLabelSHeight + contentStackPadding + checkoutHeight
		
		return total
	}
    
    func setupNavBarStyle(storeName: String?) {
        self.navigationController?.navigationBar.tintColor = .black
        let backImage = UIImage(named: "chevron.left")

        self.navigationController?.navigationBar.backIndicatorImage = backImage

        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage

        /*** If needed Assign Title Here ***/
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: storeName, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
}
