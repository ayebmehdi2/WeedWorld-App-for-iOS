//
//  CartTableViewCell.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 13/06/2023.
//

import UIKit

class CartTableViewCell: UITableViewCell {
	@IBOutlet weak var productsTableView: UITableView!
	@IBOutlet weak var totalPrice: UILabel!
	@IBOutlet weak var shopImage: UIImageView! {
		didSet {
			shopImage.layer.cornerRadius = shopImage.frame.height / 2
		}
	}
	@IBOutlet weak var cartView: UIView! {
		didSet {
			cartView.layer.cornerRadius = 12
		}
	}
	@IBOutlet weak var shopName: UILabel!
	weak var cardsVC: CardsViewController?
	let userDef = UserDefaults.standard
	var productsArrayCell: [Product] = [] {
		didSet {
			productsTableView.reloadData()
		}
	}
    @IBOutlet weak var bottomView: UIStackView!
	
    @IBOutlet weak var checkoutButton: UIButton! {
        didSet {
            checkoutButton.layer.cornerRadius = 22.5
            checkoutButton.backgroundColor = UIColor(red: 0.99, green: 0.56, blue: 0.11, alpha: 1)
        }
    }
    var naviagtionAction: (() -> Void)?
    
    
    override func awakeFromNib() {
		super.awakeFromNib()
		 productsTableView.delegate = self
		 productsTableView.dataSource = self
	}
    
    
    @IBAction func goToCheckout(_ sender: Any) {
        if let navigate = naviagtionAction {
            navigate()
        }
    }
    
}

extension CartTableViewCell: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return productsArrayCell.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellTV", for: indexPath) as! ProductsTableViewCell

		let model = productsArrayCell[indexPath.row]

		if let cartImage = model.images?.first {
			cell.cartImage.kf.setImage(with: URL(string: cartImage), placeholder: UIImage(named: "placeholder"), options: [])
		}
		cell.cartName.text = model.name
		cell.cartCategory.text = model.category
		cell.gramme.text = (model.weight?.description ?? "") + "g"
		cell.price.text = "$" + (model.discountPrice?.description ?? "")
		cell.CBDTHC.text = "THC: \(Int(model.thc ?? 0))% | CBD: \(Int(model.cbd ?? 0))%"
		cell.quantity = model.quantity ?? 0

		cell.moinsAction = {
			if cell.quantity != 1 {
				cell.quantity -= 1
				var totalPrice = Double(self.totalPrice.text?.dropFirst() ?? "0") ?? 0
				totalPrice -= Double(cell.price.text?.dropFirst() ?? "0") ?? 0
				self.totalPrice.text = "$" + String(format: "%.2f", totalPrice)
			} else {
				// Remove product
				if let products = self.userDef.data(forKey: "products") {
					let productsDecoded = try? JSONDecoder().decode([Product].self, from: products)
					guard var productsDecoded else { return }
					
					// Remove product from array given by userDefaults
					if let index = productsDecoded.firstIndex(where: { $0.productId == model.productId }) {
						productsDecoded.remove(at: index)
					}
					
					// Clear userDefaults
					self.userDef.removeObject(forKey: "products")
					
					// Create new array of products in userDefaults
					let encodedProducts = try? JSONEncoder().encode(productsDecoded)
					self.userDef.set(encodedProducts, forKey: "products")
					
					// Grouping products by storeId
					let groupedProducts = Dictionary(grouping: productsDecoded, by: { $0.storeId })
					
					// Affect new array to productArrayCell
					if let value = groupedProducts[model.storeId] {
						self.productsArrayCell = value
					}
					
					self.cardsVC?.fillData()
				}
			}
		}

		cell.plusAction = {
			cell.quantity += 1
			var totalPrice = Double(self.totalPrice.text?.dropFirst() ?? "0") ?? 0
			totalPrice += Double(cell.price.text?.dropFirst() ?? "0") ?? 0
			self.totalPrice.text = "$" + String(format: "%.2f", totalPrice)
		}

		cell.removeAction = {
			// Remove product
			if let products = self.userDef.data(forKey: "products") {
				let productsDecoded = try? JSONDecoder().decode([Product].self, from: products)
				guard var productsDecoded else { return }
				
				// Remove product from array given by userDefaults
				if let index = productsDecoded.firstIndex(where: { $0.productId == model.productId }) {
					productsDecoded.remove(at: index)
				}
				
				// Clear userDefaults
				self.userDef.removeObject(forKey: "products")
				
				// Create new array of products in userDefaults
				let encodedProducts = try? JSONEncoder().encode(productsDecoded)
				self.userDef.set(encodedProducts, forKey: "products")
				
				// Grouping products by storeId
				let groupedProducts = Dictionary(grouping: productsDecoded, by: { $0.storeId })
				
				// Affect new array to productArrayCell
				if let value = groupedProducts[model.storeId] {
					self.productsArrayCell = value
				}
				self.cardsVC?.fillData()
			}
		}

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 165
	}
}
