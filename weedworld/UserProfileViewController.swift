//
//  UserProfileViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 29/1/2023.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import SideMenu
import Kingfisher
import CoreLocation

class UserProfileViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var postsCollectionView: UICollectionView!
    @IBOutlet var underlineViewLeading: NSLayoutConstraint!
    @IBOutlet weak var addPostBtn: UIButton! {
        didSet {
            addPostBtn.layer.cornerRadius = addPostBtn.frame.height / 2
        }
    }
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var underlineView: UIView! {
        didSet {
            underlineView.layer.cornerRadius = underlineView.frame.height / 2
        }
    }
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var userCoverImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.height / 2
            userImage.layer.borderWidth = 2
            userImage.layer.borderColor = UIColor.systemBackground.cgColor
        }
    }
    @IBOutlet weak var genderLabel: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var svHeight: NSLayoutConstraint!
    @IBOutlet weak var postsCollectionBtn: UIButton!
    @IBOutlet weak var privatePostsBtn: UIButton!
    @IBOutlet weak var profileUseRBtn: UIButton!
    @IBOutlet weak var lastStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    var centerPostsConstraint: NSLayoutConstraint!
    var trailingUserConstraint: NSLayoutConstraint!
    var imageSelected = "profile"
    var animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    var postsArray: [Post] = [] {
        didSet {
            postsCollectionView.reloadData()
        }
    }
    var isFirstLoad: Bool = true
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
        getUserPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustScrollViewHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstLoad || userCoverImage.subviews.isEmpty {
            let blurEffectView = BlurEffectView()
            userCoverImage.addSubview(blurEffectView)
            isFirstLoad = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for sub in userCoverImage.subviews {
            sub.removeFromSuperview()
        }
    }
    
    func setupUI() {
        centerPostsConstraint = underlineView.centerXAnchor.constraint(equalTo: privatePostsBtn.centerXAnchor, constant: 3)
        trailingUserConstraint = underlineView.trailingAnchor.constraint(equalTo: profileUseRBtn.trailingAnchor, constant: 5)
        postsCollectionView.register(UINib(nibName: "UserPostsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    func fillData() {
        if let user = GlobalVar.user {
            if let profilePhoto = user.profilePhoto {
                userImage.kf.setImage(with: URL(string: profilePhoto), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.3))])
            }
            if let coverPhoto = user.coverPhoto {
                userCoverImage.kf.setImage(with: URL(string: coverPhoto), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.3))])
            }
            if let location = GlobalVar.userLocation {
                locationBtn.setTitle(location, for: .normal)
            }
            convertDateMediumToDate(date: user.birthday)
            genderImage.image = user.gender == "Female" ? UIImage(named: "female") : UIImage(named: "male")
            usernameLabel.text = user.username.capitalized
        }
    }
    
    func convertDateMediumToDate(date: String) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en")
        if let dateFormatted = formatter.date(from: date) {
            calculateAgeFromBirthDate(date: dateFormatted)
        }
    }
    
    func calculateAgeFromBirthDate(date: Date) {
        let now = Date()
        let birthday: Date = date
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year ?? 20
        ageLabel.text = age.description
    }
    
    func getUserPosts() {
        showActivityIndicator(view: postsCollectionView, activityIndicator: activityIndicator)
        FirebaseHelper.getPostsByUID(uid: Auth.auth().currentUser!.uid, completion: { posts in
            guard let posts = posts else {
                self.showAlert(title: "Error", message: "An error has occured.")
                return
            }
            self.postsArray = posts
            self.stopActivityIndicator(activityIndicator: self.activityIndicator)
        })
    }
    
    func adjustScrollViewHeight() {
        let contentStackHeight = lastStackView.frame.maxY
        let collectionViewHeight = postsCollectionView.contentSize.height
        svHeight.constant = contentStackHeight + collectionViewHeight
    }
    
    @IBAction func postsCollectionClick(_ sender: UIButton) {
        postsCollectionView.reloadData()
        moveLineViewToCollection()
        adjustScrollViewHeight()
    }
    
    @IBAction func privatePostsClick(_ sender: UIButton) {
        postsCollectionView.reloadData()
        moveLineViewToPrivatePosts()
        adjustScrollViewHeight()
    }
    
    @IBAction func profileUserClick(_ sender: UIButton) {
        postsCollectionView.reloadData()
        moveLineViewToUser()
        adjustScrollViewHeight()
    }
    
    func moveLineViewToCollection() {
        centerPostsConstraint.isActive = false
        trailingUserConstraint.isActive = false
        underlineViewLeading.isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func moveLineViewToPrivatePosts() {
        underlineViewLeading.isActive = false
        trailingUserConstraint.isActive = false
        centerPostsConstraint.isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func moveLineViewToUser() {
        underlineViewLeading.isActive = false
        centerPostsConstraint.isActive = false
        trailingUserConstraint.isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func showChooseOption() {
        let chooseVC = ChoosePhotosViewController(nibName: "ChoosePhotosViewController", bundle: nil)
        chooseVC.modalPresentationStyle = .fullScreen
        chooseVC.modalTransitionStyle = .coverVertical
        chooseVC.delegate = self
        present(chooseVC, animated: true)
    }
    
    func uploadUserCoverOrProfile(imageUpload: UIImage, completion: @escaping (_ url: String?) -> Void) {
        let storageRef = Storage.storage().reference().child("images/").child(imageSelected == "profile" ? "profile/" : "cover/").child(Auth.auth().currentUser!.uid)
        if let uploadData = imageUpload.jpegData(compressionQuality: 0.5) {
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
    
    func uploadUserPostImage(imagePost: UIImage, completion: @escaping (_ url: String?) -> Void) {
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
    
    func uploadProfileImage(image: UIImage, imageView: UIImageView) {
        showActivityIndicator(view: view, activityIndicator: activityIndicator)
        uploadUserCoverOrProfile(imageUpload: image, completion: { url in
            guard let url = url else {
                self.showAlert(title: "Error", message: "An error has occured.")
                self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                return
            }
            FirebaseHelper.updateUserPhotos(profilePhoto: url, completion: { success in
                if success {
                    self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                    imageView.image = image
                    GlobalVar.user?.profilePhoto = url
                }
                else {
                    self.showAlert(title: "Error", message: "An error has occured.")
                    self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                }
            })
        })
    }
    
    func uploadCoverImage(image: UIImage, imageView: UIImageView) {
        showActivityIndicator(view: view, activityIndicator: activityIndicator)
        uploadUserCoverOrProfile(imageUpload: image, completion: { url in
            guard let url = url else {
                self.showAlert(title: "Error", message: "An error has occured.")
                self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                return
            }
            FirebaseHelper.updateUserPhotos(coverPhoto: url, completion: { success in
                if success {
                    self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                    imageView.image = image
                    GlobalVar.user?.coverPhoto = url
                }
                else {
                    self.showAlert(title: "Error", message: "An error has occured.")
                    self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                }
            })
        })
    }
    
    func postFirebase(imageUrl: String? = nil, textPost: String? = nil) {
        let post = Post.init(userId: Auth.auth().currentUser!.uid, text: textPost, image: imageUrl, aspectRatio: 1, isPrivate: false)
        post.save(completion: { success in
            if success {
                self.getUserPosts()
            }
            else {
                self.showAlert(title: "Error", message: "An error has occured.")
            }
            self.stopActivityIndicator(activityIndicator: self.activityIndicator)
        })
    }
    
    @IBAction func userImageClick(_ sender: UITapGestureRecognizer) {
        imageSelected = "profile"
        showChooseOption()
    }
    
    @IBAction func editCoverClick(_ sender: UIButton) {
        imageSelected = "cover"
        showChooseOption()
    }
    
    @IBAction func addPostClick(_ sender: UIButton) {
		imageSelected = "post"
        showChooseOption()
    }
    
    @IBAction func sideMenuClick(_ sender: UIButton) {
        showSideMenu()
    }
}

extension UserProfileViewController: ChooseOptionDelegate {
	
	func passData(_ image: UIImage, _ previousImage: UIImage, _ text: String) {
		if imageSelected == "profile" {
			self.uploadProfileImage(image: image, imageView: self.userImage)
			
		} else if imageSelected == "cover" {
			self.uploadCoverImage(image: image, imageView: self.userCoverImage)
			
		} else {
			if image != previousImage {
				showActivityIndicator(view: view, activityIndicator: activityIndicator)
				uploadUserPostImage(imagePost: image, completion: { url in
					guard let url = url else {
						self.showAlert(title: "Error", message: "An error has occured.")
						self.stopActivityIndicator(activityIndicator: self.activityIndicator)
						return
					}
					text != "" ? self.postFirebase(imageUrl: url, textPost: text) : self.postFirebase(imageUrl: url)
				})
			}
			else {
				postFirebase(textPost: text)
			}
		}
	}
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserPostsCollectionViewCell
        
        let model = postsArray[indexPath.item]
        
        if let postImage = model.image {
            cell.postImage.kf.setImage(with: URL(string: postImage), placeholder: UIImage(named: "placeholder"), options: [])
            cell.postImage.backgroundColor = .clear
		} else {
			cell.postImage.backgroundColor = .systemGray5
			cell.postImage.image = UIImage()
		}
        
        if let postText = model.text {
            cell.textPost.text = postText
            cell.textPost.isHidden = false
		} else {
			cell.textPost.isHidden = true
		}
		
		if let postId = model.postId {
			FirebaseHelper.getPostComments(postId: postId, completion: { comments in
				guard let comments = comments else { return }
				cell.commentNbr.setTitle(comments.count.description, for: .normal)
			})
			
			FirebaseHelper.getPostLikes(postId: postId, completion: { likess in
				guard let likes = likess else { return }
				cell.likesNbr.setTitle(likes.count.description, for: .normal)
			})
		}
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 45 // Left and Right UIEdgeInsets + minimumInteritemSpacingForSectionAt
        let collectionViewSize = collectionView.bounds.width - padding
        let width = collectionViewSize / 2
        return CGSize(width: width, height: width + padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 30, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
