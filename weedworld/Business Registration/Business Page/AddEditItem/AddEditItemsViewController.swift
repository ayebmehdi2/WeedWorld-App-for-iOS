//
//  AddEditItemsViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 30/05/2023.
//

import UIKit
import Kingfisher
import PhotosUI

class AddEditItemsViewController: UIViewController {

	@IBOutlet weak var itemsImageCollectionView: UICollectionView!
	@IBOutlet weak var productNameTF: UITextField!
	@IBOutlet weak var brandNameTF: UITextField!
	@IBOutlet weak var categoryBtn: UIButton!
	@IBOutlet weak var weightTF: UITextField!
	@IBOutlet weak var discountPriceTF: UITextField!
	@IBOutlet weak var priceTF: UITextField!
	@IBOutlet weak var cbdTF: UITextField!
	@IBOutlet weak var typeStackView: UIStackView!
	@IBOutlet weak var thcTF: UITextField!
	@IBOutlet weak var typeBtn: UIButton!
	@IBOutlet weak var descriptionTextView: UITextView! {
		didSet {
			descriptionTextView.layer.cornerRadius = 6
			descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		}
	}
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	var passedProduct: Product?
	var itemsAdded: [UIImage] = [UIImage()]
	var isEdit = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
		fillData()
		setupCategoryAndTypeBtn()
    }
	
	func fillData() {
		if let passedProduct = passedProduct {
			passedProduct.images?.insert("", at: 0)
			productNameTF.text = passedProduct.name
			brandNameTF.text = passedProduct.brand
			categoryBtn.setTitle(passedProduct.category, for: .normal)
			thcTF.text = passedProduct.thc?.description
			cbdTF.text = passedProduct.cbd?.description
			priceTF.text = passedProduct.price?.description
			discountPriceTF.text = passedProduct.discountPrice?.description
			weightTF.text = passedProduct.weight?.description
			descriptionTextView.text = passedProduct.description
		}
	}
	
	func setupCategoryAndTypeBtn() {
		categoryBtn.showsMenuAsPrimaryAction = true
		typeBtn.showsMenuAsPrimaryAction = true
		categoryBtn.menu = createCategoryMenu()
		typeBtn.menu = createTypeMenu()
	}
	
	func createCategoryMenu() -> UIMenu? {
		let menu = UIMenu(title: "", children: [
			
			UIAction(title: "Flower") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Pre Rolls") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Edibles") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Vape Carts") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "CBD") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Concentrates") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Oil") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Vaping") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Topicals") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Accessories") { action in
				self.typeStackView.isHidden = true
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Seeds") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Clones") { action in
				self.typeStackView.isHidden = false
				self.categoryBtn.setTitle(action.title, for: .normal)
			}
		])
		
		return menu
	}
	
	func createTypeMenu() -> UIMenu? {
		let menu = UIMenu(title: "", children: [
			
			UIAction(title: "Indica") { action in
				self.typeBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Sativa") { action in
				self.typeBtn.setTitle(action.title, for: .normal)
			},
			
			UIAction(title: "Hybrid") { action in
				self.typeBtn.setTitle(action.title, for: .normal)
			}
		])
		
		return menu
	}
	
	func updateProduct() async -> Bool {
		if let productId = passedProduct?.productId {
			showActivityIndicator(view: view, activityIndicator: activityIndicator)
			passedProduct?.images?.removeFirst()
			let product = Product(brand: brandNameTF.text, category: categoryBtn.title(for: .normal), cbd: Float(cbdTF.text ?? ""), description: descriptionTextView.text, discountPrice: Double(discountPriceTF.text ?? ""), images: passedProduct?.images, name: productNameTF.text, nameLowerCase: passedProduct?.nameLowerCase, price: Double(priceTF.text ?? ""), storeId: passedProduct?.storeId, thc: Float(thcTF.text ?? ""), weight: Float(weightTF.text ?? ""), productId: productId)
			
			let resultUpdate = try! await FirebaseHelper.updateProduct(productId: productId, product: product)
			
			return resultUpdate
		}
		return false
	}
	
	@IBAction func buttonClick(_ sender: UIButton) {
		guard isEdit else {
			return
		}
		Task {
			async let result = updateProduct()
			await result ? showAlert(title: "Alert", message: "Success") : showAlert(title: "Alert", message: "Error")
			stopActivityIndicator(activityIndicator: activityIndicator)
		}
	}
	
	@IBAction func backButtonClick(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
}

extension AddEditItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let imagesArray = passedProduct?.images {
			return imagesArray.count
		}
		return itemsAdded.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AddEditItemCollectionViewCell
		
		if indexPath.item == 0 {
			cell.plusImage.isHidden = false
			cell.itemImage.image = UIImage()
			cell.itemImage.backgroundColor = .systemGray5
		} else {
			cell.plusImage.isHidden = true
			cell.itemImage.backgroundColor = .systemGray
			if let itemImages = passedProduct?.images {
				cell.itemImage.kf.setImage(with: URL(string: itemImages[indexPath.item]), placeholder: UIImage(named: "placeholder"), options: [])
			}
			else {
				cell.itemImage.image = itemsAdded[indexPath.item]
			}
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showImagePicker()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 60, height: collectionView.frame.height)
	}
}

// MARK: Library
extension AddEditItemsViewController: PHPickerViewControllerDelegate {
	
	func showImagePicker() {
		var config = PHPickerConfiguration()
		config.selectionLimit = 1
		config.filter = .images
		let imagePicker = PHPickerViewController(configuration: config)
		imagePicker.delegate = self
		present(imagePicker, animated: true)
	}
	
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		dismiss(animated: true)
		
		if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
			
			itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] image, error in
				DispatchQueue.main.async {
					guard let `self` = self, let image = image as? UIImage else { return }
					self.itemsAdded.append(image)
				}
			})
		}
	}
}
