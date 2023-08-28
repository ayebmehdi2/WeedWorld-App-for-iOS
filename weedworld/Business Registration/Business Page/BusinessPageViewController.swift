//
//  BusinessPageViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 09/05/2023.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseStorage

class BusinessPageViewController: UIViewController {
	
	@IBOutlet weak var coverImage: UIImageView! {
		didSet {
			coverImage.layer.cornerRadius = 20
			coverImage.layer.masksToBounds = true
			coverImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		}
	}
	@IBOutlet weak var addPostBtn: UIButton! {
		didSet {
			addPostBtn.layer.cornerRadius = addPostBtn.frame.height / 2
		}
	}
    
    @IBOutlet weak var ordersButton: UIButton! {
        didSet {
            ordersButton.layer.cornerRadius = ordersButton.frame.height / 2
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var storeId: UILabel!
	@IBOutlet weak var storeName: UILabel!
	@IBOutlet weak var storeView: UIView!
	@IBOutlet weak var categoriesCollectionView: UICollectionView!
	@IBOutlet weak var socialView: UIView!
	@IBOutlet weak var socialCollectionView: UICollectionView!
	@IBOutlet weak var infoBtn: UIButton!
	@IBOutlet weak var itemsTableView: UITableView!
	@IBOutlet weak var storeImage: UIImageView! {
		didSet {
			storeImage.layer.cornerRadius = storeImage.frame.height / 2
			storeImage.layer.borderWidth = 3
			storeImage.layer.borderColor = UIColor.customGreen.cgColor
		}
	}
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	var categoriesArray = ["All", "Flower", "Pre-Rolls", "Edibles", "Vape Carts", "CBD", "Concentrates", "Oil", "Vaping", "Topicals", "Accessories", "Seeds", "Clones"]
	var categoriesImages = ["", "flower", "prerolls", "edibles", "vapeCarts", "cbdBusiness", "concentrates", "oil", "vaping", "topicals", "accessories", "seeds", "clones"]
	var passedStore: LocalStore?
	var productsArray: [Product] = []
	var productsArrayFiltred: [Product] = [] {
		didSet {
			stopActivityIndicator(activityIndicator: activityIndicator)
			itemsTableView.reloadData()
		}
	}
	var postsArray: [Post] = [] {
		didSet {
			socialCollectionView.reloadData()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		fillData()
		Task {
			// Start both tasks concurrently
			async let items = getItems()
			async let posts = getStorePosts()

			// Await both tasks to complete
			productsArray = await items
			productsArrayFiltred = await items
			postsArray = await posts
		}
    }
	
	func setup() {
		// TableView and CollectionView
		itemsTableView.register(UINib(nibName: "ItemsBusinessTableViewCell", bundle: nil), forCellReuseIdentifier: "cellTV")
		categoriesCollectionView.register(UINib(nibName: "CategorisBusinessCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellCV")
		socialCollectionView.register(UINib(nibName: "SocialCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellSocial")
		
		// Segmented Control
		let attribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
		segmentedControl.setTitleTextAttributes(attribute, for: .selected)
		
		// Info button
		infoBtn.showsMenuAsPrimaryAction = true
		infoBtn.menu = createMenu()
	}
	
	func fillData() {
		if let store = passedStore {
			storeName.text = store.businessName?.capitalized
			if let storeId = store.storeId {
				self.storeId.text = "WW ID: " + storeId
			}
			if let photo = store.photo {
				storeImage.kf.setImage(with: URL(string: photo), placeholder: UIImage(named: "placeholder"), options: [])
			}
			if let coverPhoto = store.coverPhoto {
				coverImage.kf.setImage(with: URL(string: coverPhoto), placeholder: UIImage(named: "placeholder"), options: [])
			}
		}
	}
	
	func createMenu() -> UIMenu? {
		guard let store = passedStore else { return nil }
		
		let menu = UIMenu(title: store.businessName ?? "", children: [
			
			UIAction(title: store.phone ?? "", image: UIImage(systemName: "phone.fill")) { action in },
			
			UIAction(title: store.emailAddress ?? "", image: UIImage(systemName: "envelope.fill")) { action in },
			
			UIAction(title: store.website ?? "", image: UIImage(systemName: "newspaper.fill")) { action in }
		])
		
		return menu
	}
	
	func getItems() async -> [Product] {
		if let storeId = passedStore?.storeId {
			showActivityIndicator(view: view, activityIndicator: activityIndicator)
			let products = try? await FirebaseHelper.getItemsByStoreId(storeId: storeId)
			guard let products = products else {
				showAlert(title: "Error", message: "An error has occured please try later.")
				return []
			}
			return products
		}
		return []
	}

	func getStorePosts() async -> [Post] {
		if let storeId = passedStore?.storeId {
			let posts = try? await FirebaseHelper.getPostsByStoreId(storeId: storeId)
			guard let posts = posts else {
				showAlert(title: "Error", message: "An error has occured please try later.")
				return []
			}
			return posts
		}
		return []
	}
	
	func showChooseOption() {
		let chooseVC = ChoosePhotosViewController(nibName: "ChoosePhotosViewController", bundle: nil)
		chooseVC.modalPresentationStyle = .fullScreen
		chooseVC.modalTransitionStyle = .coverVertical
		chooseVC.delegate = self
		present(chooseVC, animated: true)
	}
	
	func uploadStorePostImage(imagePost: UIImage, completion: @escaping (_ url: String?) -> Void) {
		let randomName = UUID()
		let storageRef = Storage.storage().reference().child("images/").child("/posts").child(randomName.uuidString)
		if let uploadData = imagePost.jpegData(compressionQuality: 0.5) {
			let metaData = StorageMetadata()
			metaData.contentType = "image/jpeg"
			storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
				guard let error = error else {
					storageRef.downloadURL(completion: { (url, error) in
						guard let url = url else {
							print("Error", error!.localizedDescription)
							completion(nil)
							return
						}
						completion(url.absoluteString)
					})
					return
				}
				print("Error", error.localizedDescription)
				completion(nil)
			}
		}
	}
	
	func postFirebase(imageUrl: String? = nil, textPost: String? = nil) {
		if let storeId = passedStore?.storeId {
			let post = Post(userId: Auth.auth().currentUser!.uid, text: textPost, image: imageUrl, aspectRatio: 1, isPrivate: false, storeId: storeId)
			post.save(completion: { success in
				if success {
					Task {
						async let posts = self.getStorePosts()
						self.postsArray = await posts
					}
				} else {
					self.showAlert(title: "Error", message: "An error has occured.")
				}
				self.stopActivityIndicator(activityIndicator: self.activityIndicator)
			})
		}
	}
	
	@IBAction func editStoreBtnClick(_ sender: UIButton) {
		let storyBoard = UIStoryboard(name: "EditStore", bundle: nil)
		let editVC = storyBoard.instantiateViewController(withIdentifier: "editVC") as! UINavigationController
		editVC.modalPresentationStyle = .fullScreen
		editVC.modalTransitionStyle = .crossDissolve
		present(editVC, animated: true)
	}
	
	@IBAction func addBtnClick(_ sender: UIButton) {
		if !socialView.isHidden {
			showChooseOption()
		} else {
			let storyBoard = UIStoryboard(name: "Items", bundle: nil)
			let itemVC = storyBoard.instantiateViewController(withIdentifier: "itemVC") as! UINavigationController
			itemVC.modalPresentationStyle = .fullScreen
			itemVC.modalTransitionStyle = .crossDissolve
			self.present(itemVC, animated: true)
		}
	}
	
	@IBAction func segmentedControlClick(_ sender: UISegmentedControl) {
		if segmentedControl.selectedSegmentIndex == 0 {
			storeView.isHidden = false
			socialView.isHidden = true
		} else {
			storeView.isHidden = true
			socialView.isHidden = false
		}
	}
	
	@IBAction func backButtonClick(_ sender: UIButton) {
		dismiss(animated: true)
	}
    
    @IBAction func goToOrders(_ sender: Any) {
        let orders = StoreOrdersViewController()
        orders.store = passedStore
        orders.modalTransitionStyle = .crossDissolve
        orders.modalPresentationStyle = .fullScreen
        present(orders, animated: true)
    }
    
}

extension BusinessPageViewController: ChooseOptionDelegate {
	func passData(_ image: UIImage, _ previousImage: UIImage, _ text: String) {
		showActivityIndicator(view: view, activityIndicator: activityIndicator)
		uploadStorePostImage(imagePost: image, completion: { url in
			guard let url = url else {
				self.showAlert(title: "Error", message: "An error has occured.")
				self.stopActivityIndicator(activityIndicator: self.activityIndicator)
				return
			}
			self.postFirebase(imageUrl: url)
		})
	}
}


extension BusinessPageViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return productsArrayFiltred.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellTV", for: indexPath) as! ItemsBusinessTableViewCell
		
		let model = productsArray[indexPath.row]
		
		cell.brandName.text = model.brand
		cell.name.text = model.name
		cell.categoryName.text = model.category
		cell.THCCBD.text = "THC: \(model.thc ?? 0)% | CBD: \(model.cbd ?? 0)%"
		let attributeString = NSMutableAttributedString(string: "$" + (model.price?.description ?? ""))
		
		// Add strikethrough style
		attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
		
		// Add red color to the strikethrough style
		attributeString.addAttribute(.strikethroughColor, value: UIColor.red, range: NSRange(location: 0, length: attributeString.length))

		cell.price.attributedText = attributeString
		cell.grammeLabel.text = Int(model.weight ?? 0).description + "g"
		cell.discountPrice.text = "$" + (model.discountPrice?.description ?? "-")
		cell.itemImage.kf.setImage(with: URL(string: model.images?.first ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyBoard = UIStoryboard(name: "ItemDetails", bundle: nil)
		let itemVC = storyBoard.instantiateViewController(withIdentifier: "itemDetailsVC") as! UINavigationController
		let child = itemVC.children.first as! ItemDetailsViewController
		child.passedItem = productsArray[indexPath.row]
		present(itemVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let askAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
			self.showDeleteAlert(index: indexPath.row)
			complete(true)
		}
		
		// Here set your image and background color
		askAction.image = UIImage(systemName: "trash.fill")
		askAction.backgroundColor = .customGreen
		
		return UISwipeActionsConfiguration(actions: [askAction])
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let askAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
			let storyBoard = UIStoryboard(name: "Items", bundle: nil)
			let itemVC = storyBoard.instantiateViewController(withIdentifier: "itemVC") as! UINavigationController
			let itemVCchild = itemVC.children.first as! AddEditItemsViewController
			itemVC.modalPresentationStyle = .fullScreen
			itemVC.modalTransitionStyle = .crossDissolve
			itemVCchild.isEdit = true
			itemVCchild.passedProduct = self.productsArray[indexPath.row]
			self.present(itemVC, animated: true)
		}
		
		// Here set your image and background color
		askAction.image = UIImage(systemName: "pencil")
		askAction.backgroundColor = .customGreen
		
		return UISwipeActionsConfiguration(actions: [askAction])
	}
	
	func showDeleteAlert(index: Int) {
		let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this product ?", preferredStyle: .alert)
		let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
		let product = productsArray[index]
		let yesAction = UIAlertAction(title: "YES", style: .default, handler: { _ in
			Task {
				let productDeleted = try! await FirebaseHelper.deleteProduct(productId: product.productId ?? "")
				if productDeleted {
					self.productsArrayFiltred.remove(at: index)
				} else {
					self.showAlert(title: "Error", message: "An error has occured.")
				}
			}
		})
		alert.addAction(yesAction)
		alert.addAction(noAction)
		present(alert, animated: true)
	}
		
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let stackHeight: CGFloat = 60
		let padding: CGFloat = 30
		let total: CGFloat = stackHeight + padding
		return total
	}
}

extension BusinessPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == categoriesCollectionView ? categoriesArray.count : postsArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == categoriesCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCV", for: indexPath) as! CategorisBusinessCollectionViewCell
			
			let model = categoriesArray[indexPath.item]
			cell.categorieTitle.text = model
			
			if model == "All" {
				cell.allLabel.isHidden = false
				cell.categorieTitle.isHidden = true
				cell.categorieImage.image = UIImage()
				cell.categorieImage.backgroundColor = .systemGray6
			} else {
				cell.allLabel.isHidden = true
				cell.categorieImage.image = UIImage(named: categoriesImages[indexPath.item])
				cell.categorieTitle.isHidden = false
			}
			
			return cell
			
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellSocial", for: indexPath) as! SocialCollectionViewCell
			
			let model = postsArray[indexPath.item]
			
			if let postImage = model.image {
				cell.postImage.kf.setImage(with: URL(string: postImage), placeholder: UIImage(named: "placeholder"), options: [])
				cell.postImage.backgroundColor = .clear
			} else {
				cell.postImage.backgroundColor = .systemGray5
				cell.postImage.image = UIImage()
			}

			if let postText = model.text {
				cell.postText.text = postText
				cell.postText.isHidden = false
			} else {
				cell.postText.isHidden = true
			}
			
			if let postId = model.postId {
				FirebaseHelper.getPostComments(postId: postId, completion: { comments in
					guard let comments = comments else { return }
					cell.postComments.setTitle(comments.count.description, for: .normal)
				})
				
				FirebaseHelper.getPostLikes(postId: postId, completion: { likess in
					guard let likes = likess else { return }
					cell.postLikes.setTitle(likes.count.description, for: .normal)
				})
			}
			
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == categoriesCollectionView {
			let selectedCategory = categoriesArray[indexPath.item]
			selectedCategory == "All" ? (productsArrayFiltred = productsArray) : (productsArrayFiltred = productsArray.filter { $0.category == selectedCategory })
			
		} else {
			let detailsVC = NewsDetailsViewController(nibName: "NewsDetailsViewController", bundle: nil)
			detailsVC.modalPresentationStyle = .formSheet
			detailsVC.passedPost = postsArray[indexPath.item]
			present(detailsVC, animated: true)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == categoriesCollectionView {
			let imageHeight: CGFloat = 50
			let labelHeight: CGFloat = 25
			let total = imageHeight + labelHeight
			
			return CGSize(width: 50, height: total)
			
		} else {
			let padding: CGFloat = 45 // Left and Right UIEdgeInsets + minimumInteritemSpacingForSectionAt
			let collectionViewSize = collectionView.bounds.width - padding
			let width = collectionViewSize / 2
			return CGSize(width: width, height: width + padding)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		if collectionView == categoriesCollectionView {
			return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
			
		} else {
			return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
		}
	}
}
