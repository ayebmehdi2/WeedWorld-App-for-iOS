//
//  NewsFeedViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher

class NewsFeedViewController: UIViewController {
    
    @IBOutlet weak var newsCollectionView: UICollectionView!
    var postsArray: [Post] = [] {
        didSet {
            newsCollectionView.reloadData()
        }
    }
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUserPosts()
    }
    
    func setupUI() {
        newsCollectionView.register(UINib(nibName: "NewssFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellNews")
    }
    
    func getUserPosts() {
        showActivityIndicator(view: view, activityIndicator: activityIndicator)
        FirebaseHelper.getAllPosts(completion: { posts in
            guard let posts = posts else {
                self.showAlert(title: "Error", message: "An error has occured.")
                return
            }
            self.postsArray = posts
            self.stopActivityIndicator(activityIndicator: self.activityIndicator)
        })
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        let editVC = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        editVC.modalTransitionStyle = .crossDissolve
        editVC.modalPresentationStyle = .fullScreen
        present(editVC, animated: true)
    }
    
    @IBAction func menuClick(_ sender: UIBarButtonItem) {
        showSideMenu()
    }
    
}

extension NewsFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellNews", for: indexPath) as! NewssFeedCollectionViewCell
        
        let model = postsArray[indexPath.item]
        
        if let postImage = model.image {
            cell.newsImage.kf.setImage(with: URL(string: postImage), placeholder: UIImage(named: "placeholder"), options: [])
            cell.newsImage.backgroundColor = .clear
        }
        else {
            cell.newsImage.backgroundColor = .systemGray5
            cell.newsImage.image = UIImage()
        }
        
        if let postText = model.text {
            cell.postLabel.text = postText
            cell.postLabel.isHidden = false
        }
        else {
            cell.postLabel.isHidden = true
        }
        
        if let postId = model.postId {
            FirebaseHelper.getPostComments(postId: postId, completion: { comments in
                guard let comments = comments else { return }
                cell.commentsNbr.setTitle(comments.count.description, for: .normal)
            })
            
            FirebaseHelper.getPostLikes(postId: postId, completion: { likess in
                guard let likes = likess else { return }
                cell.likesNbr.setTitle(likes.count.description, for: .normal)
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = NewsDetailsViewController(nibName: "NewsDetailsViewController", bundle: nil)
        detailsVC.passedPost = postsArray[indexPath.item]
        navigationController?.pushViewController(detailsVC, animated: true)
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
