//
//  ItemDetailsViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 31/05/2023.
//

import UIKit
import Kingfisher

class ItemDetailsViewController: UIViewController {

	@IBOutlet weak var containerView: UIView! {
		didSet {
			containerView.layer.cornerRadius = 20
		}
	}
	@IBOutlet weak var quantityLabel: UILabel!
	@IBOutlet weak var addView: UIView! {
		didSet {
			addView.layer.cornerRadius = addView.frame.height / 2
		}
	}
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var itemImage: UIImageView!
	@IBOutlet weak var brandName: UILabel!
	@IBOutlet weak var category2: UILabel!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var category: UILabel!
	@IBOutlet weak var descriptionTV: UITextView!
	@IBOutlet weak var CBD: UILabel!
	@IBOutlet weak var THC: UILabel!
	@IBOutlet weak var addedCartView: UIView! {
		didSet {
			addedCartView.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var addedCartPrice: UILabel!
	@IBOutlet weak var addedCartQuantity: UILabel!
	@IBOutlet var addedCartConstraint: NSLayoutConstraint!
	var addedCartBottomConstraint: NSLayoutConstraint!
	let userDef = UserDefaults.standard
	var passedItem: Product?
	var quantity = 1 {
		didSet {
			quantityLabel.text = quantity.description
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		fillData()
    }
	
	func fillData() {
		if let product = passedItem {
			itemImage.kf.setImage(with: URL(string: product.images?.first ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
			price.text = "$" + (product.price?.description ?? "")
			brandName.text = product.brand
			category.text = product.category
			category2.text = product.category
			name.text = product.name
			descriptionTV.text = product.description
			THC.text = "THC: " + (product.thc?.description ?? "") + "% |"
			CBD.text = "CBD: " + (product.cbd?.description ?? "") + "%"
		}
		addedCartBottomConstraint = addedCartView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
	}
	
	@IBAction func imageTap(_ sender: UITapGestureRecognizer) {
		let storyBoard = UIStoryboard(name: "ImagesItem", bundle: nil)
		let imagesVC = storyBoard.instantiateViewController(withIdentifier: "imagesVC") as! UINavigationController
		let imagesChild = imagesVC.children.first as! ImagesItemViewController
		imagesChild.imagesArray = passedItem?.images ?? []
		present(imagesVC, animated: true)
	}
	
	@IBAction func moinsBtn(_ sender: UIButton) {
		guard quantity != 1 else { return }
		quantity -= 1
	}
	
	@IBAction func plusBtnClick(_ sender: UIButton) {
		quantity += 1
	}
	
	@IBAction func addCardClick(_ sender: UIButton) {
		if let encodedProducts = userDef.data(forKey: "products") {
			do {
				// Decode the products array from the encoded data
				var decodedProducts = try JSONDecoder().decode([Product].self, from: encodedProducts)
				
				// Use the decoded products array
				userDef.removeObject(forKey: "products")
				if let passedItem = passedItem {
					// Add quantity to the model
					passedItem.quantity = quantity
					decodedProducts.append(passedItem)
					let encodedProducts = try? JSONEncoder().encode(decodedProducts)
					userDef.set(encodedProducts, forKey: "products")
				}
			} catch {
				print("Error decoding products: \(error)")
			}
		} else {
			// Add quantity to the model
			passedItem?.quantity = quantity
			if let encoded = try? JSONEncoder().encode([passedItem]) {
				userDef.set(encoded, forKey: "products")
			}
		}
		showAddedCart()
	}
	
	func showAddedCart() {
		if let product = passedItem, let price = product.price {
			addedCartPrice.text = "$" + (price * Double(quantity)).description
		}
		addedCartQuantity.text = "x" + quantity.description
		addedCartConstraint.isActive = false
		addedCartBottomConstraint.isActive = true
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
		}, completion: { _ in
			self.hideCart()
		})
	}
	
	func hideCart() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
			self.addedCartBottomConstraint.isActive = false
			self.addedCartConstraint.isActive = true
			UIView.animate(withDuration: 0.3, animations: {
				self.view.layoutIfNeeded()
			})
		})
	}
	
	@IBAction func backClick(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
}
