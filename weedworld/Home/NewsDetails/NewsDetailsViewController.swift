//
//  NewsDetailsViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 27/2/2023.
//

import UIKit
import Kingfisher
import FirebaseAuth

class NewsDetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var postImage: UIImageView! {
        didSet {
            postImage.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var postTF: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datePost: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var addCommentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentImageUser: UIImageView! {
        didSet {
            commentImageUser.layer.cornerRadius = commentImageUser.frame.height / 2
        }
    }
    @IBOutlet weak var addCommentTF: UITextField! {
        didSet {
            addCommentTF.layer.cornerRadius = 8
            addCommentTF.setLeftPaddingPoints(10)
        }
    }
    @IBOutlet weak var viewAllCommentStack: UIStackView!
    @IBOutlet weak var viewAllCommentsBtn: UIButton!
    let formatter = DateFormatter()
    var commentsArray: [Comment] = [] {
        didSet {
            commentsTableView.reloadData()
            adjustTableViewHeight()
        }
    }
    var commentsArrayCopy: [Comment] = []
    var usersArray: [User] = []
    var passedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMoreButton()
        addNotificationObservers()
        hideKeyboardWhenTappedAround()
        setupTableView()
        fillData()
    }
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableViewHeight()
    }
    
    func adjustTableViewHeight() {
        tableViewHeight.constant = commentsTableView.contentSize.height + 10
        commentsTableView.layoutIfNeeded()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard addCommentTF.isFirstResponder else { return }
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let tabbarHeight = tabBarController?.tabBar.frame.height
            addCommentBottomConstraint.constant = keyboardSize.size.height - (tabbarHeight ?? 0)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        addCommentBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupTableView() {
        commentsTableView.register(UINib(nibName: "NewsDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        addCommentTF.returnKeyType = .done
        postTF.returnKeyType = .done
    }
    
    func fillData() {
        if let urlImage = passedPost?.image {
            postImage.kf.setImage(with: URL(string: urlImage), placeholder: UIImage(named: "placeholder"), options: [])
        }
        else {
            postImage.backgroundColor = .systemGray5
        }
        
        if let postText = passedPost?.text {
            postTF.text = postText
        }
        
        if let time = passedPost?.timestamp {
            let date = time.dateValue()
            formatter.dateStyle = .long
            formatter.locale = Locale(identifier: "en")
            let dateFormatted = formatter.string(from: date)
            timeLabel.text = dateFormatted
        }
        if let uid = passedPost?.userId {
            FirebaseHelper.getUserByUID(uid: uid, completion: { user in
                guard let user = user else { return }
                
                DispatchQueue.main.async {
                    self.userName.text = user.username.capitalized
                }
            })
        }
        if let user = GlobalVar.user {
            commentImageUser.kf.setImage(with: URL(string: user.profilePhoto ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
        }
        if let postId = passedPost?.postId {
            let myGroup = DispatchGroup()
            
            FirebaseHelper.getPostComments(postId: postId, completion: { comments in
                guard let comments = comments else { return }
                
                self.commentsBtn.setTitle(comments.count.description, for: .normal)
                self.viewAllCommentsBtn.setTitle("View all comments (\(comments.count))", for: .normal)
                
                for comment in comments {
                    myGroup.enter()
                    FirebaseHelper.getUserByUID(uid: comment.userId ?? "", completion: { user in
                        guard let user = user else {
                            return
                        }
                        self.usersArray.append(user)
                        myGroup.leave()
                    })
                }
                myGroup.notify(queue: .main) {
                    let commentsArraySliced = Array(comments.suffix(3))
                    self.commentsArrayCopy = comments
                    self.commentsArray = commentsArraySliced
                    self.adjustTableViewHeight()
                }
            })
            
            FirebaseHelper.getPostLikes(postId: postId, completion: { likess in
                guard let likes = likess else { return }
                self.likesBtn.setTitle(likes.count.description, for: .normal)
                
                for like in likes {
                    if like.userId == Auth.auth().currentUser!.uid {
                        self.likesBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    }
                }
            })
        }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" && textField == addCommentTF {
            saveCommentFirebase(comment: textField.text!)
            textField.text = ""
        }
        else if textField.text != "" && textField == postTF {
            editPost(text: textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func saveCommentFirebase(comment: String) {
        let comment = Comment.init(content: comment, postId: passedPost?.postId, userId: Auth.auth().currentUser!.uid)
        
        comment.save(completion: { success in
            
            if success {
                DispatchQueue.main.async {
                    print("successs")
                }
            }
            else {
                self.showAlert(title: "Error", message: "An error has occured, please try later !")
            }
        })
    }
    
    func editPost(text: String) {
        if let postId = passedPost?.postId {
            FirebaseHelper.editPost(postId: postId, text: text, completion: { success in
                
                if success {
                    print("success")
                }
                else {
                    self.showAlert(title: "Error", message: "An error has occured, please try later !")
                }
            })
        }
    }
    
    func likePost(postId: String, userId: String) {
        let like = Like.init(postId: postId, userId: userId)
        like.save(completion: { success in
            if !success {
                self.showAlert(title: "Error", message: "An error has occured, please try later !")
            }
        })
    }
    
    func removeLike(postId: String, userId: String) {
        let like = Like.init(postId: postId, userId: userId)
        like.delete(completion: { success in
            if !success {
                self.showAlert(title: "Error", message: "An error has occured, please try later !")
            }
            else {
                self.likesBtn.setImage(UIImage(named: "profileHeartIcon2"), for: .normal)
            }
        })
    }
    
    func addMoreButton() {
        guard passedPost?.userId == Auth.auth().currentUser!.uid else { return }
        let image = UIImage(named: "more")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(moreClick))
        button.tintColor = .systemGray
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func moreClick() {
        let popup = EditOrDeleteDetailsViewController(nibName: "EditOrDeleteDetailsViewController", bundle: nil)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.delegate = self
        present(popup, animated: true)
    }
    
    @IBAction func likeBtnClick(_ sender: UIButton) {
        if let postId = passedPost?.postId {
            likesBtn.image(for: .normal) == UIImage(systemName: "heart.fill") ? removeLike(postId: postId, userId: Auth.auth().currentUser!.uid) : likePost(postId: postId, userId: Auth.auth().currentUser!.uid)
        }
    }
    
    @IBAction func viewAllCommentClick(_ sender: UIButton) {
        viewAllCommentStack.isHidden = true
        commentsArray = commentsArrayCopy
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        let popup = RepostViewController(nibName: "RepostViewController", bundle: nil)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.repostTitleText = "Repost this by " + (userName.text ?? "") + " ?"
        present(popup, animated: true)
    }
    
    @IBAction func postItmageClick(_ sender: UITapGestureRecognizer) {
        if let _ = passedPost?.image {
            let imageViewer = ImageViewerViewController(nibName: "ImageViewerViewController", bundle: nil)
            imageViewer.passedImage = postImage.image
            imageViewer.modalPresentationStyle = .overFullScreen
            imageViewer.modalTransitionStyle = .crossDissolve
            present(imageViewer, animated: true)
        }
    }
}

extension NewsDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsDetailsTableViewCell
        
        cell.userComment.text = commentsArray[indexPath.row].content
        cell.userImage.kf.setImage(with: URL(string: usersArray[indexPath.row].profilePhoto ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
        cell.userName.text = usersArray[indexPath.row].username.capitalized
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension NewsDetailsViewController: EditOrDeleteDelegate {
    
    func deleteSelected() {
        showSureAlert()
    }
    
    func editSelected() {
        postTF.isUserInteractionEnabled = true
        postTF.becomeFirstResponder()
    }
    
    func showSureAlert() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this post ?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            if let postId = self.passedPost?.postId {
                FirebaseHelper.deletePost(postId: postId, completion: { success in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.showAlert(title: "Alert", message: "An error has occured, try later.")
                    }
                })
            }
        })
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(action)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
}
