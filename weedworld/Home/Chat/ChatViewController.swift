//
//  ChatViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import UIKit
import Kingfisher
import FirebaseAuth

class ChatViewController: UIViewController {

    @IBOutlet weak var searchTF: UITextField! {
        didSet {
            searchTF.layer.cornerRadius = searchTF.frame.height / 2
        }
    }
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var onlineFriendsCollectionView: UICollectionView!
    var usersArray: [User] = []
    var groupsArray: [String] = [] {
        didSet {
            groupsTableView.reloadData()
        }
    }
    var selectedIndex = 0
    var nbRows = 2
    let imagesArray = ["ronaldo", "messi"]
    let namesArray = ["Fares", "Messi"]
    let lastMessage = ["Hey", "You sent an emoji"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getOnlineUsers()
        getChatGroups()
    }
    
    func setupUI() {
        chatTableView.contentInset.top = 15
        chatTableView.contentInset.bottom = 15
        searchTF.addLeftImage(imageName: "search")
    }
        
    func getOnlineUsers() {
        let myGroup = DispatchGroup()
		
        FirebaseHelper.getOnlineUsers(completion: { UIDS in
            guard let usersUIDS = UIDS else { return }
            for uid in usersUIDS {
                myGroup.enter()
                
                FirebaseHelper.getUserByUID(uid: uid, completion: { user in
                    guard let user = user else {
                        return
                    }
                    self.usersArray.append(user)
                    myGroup.leave()
                })
            }
            myGroup.notify(queue: .main) {
                self.onlineFriendsCollectionView.reloadData()
            }
        })
    }
    
    func getChatGroups() {
        FirebaseHelper.getUserChatGroups(uid: Auth.auth().currentUser!.uid, completion: { chats in
            guard let names = chats else { return }
            self.groupsArray = names
        })
    }
    
    @IBAction func chatGroupsClick(_ sender: UIBarButtonItem) {
        chatTableView.isHidden = true
        groupsTableView.isHidden = false
    }
    
    @IBAction func conversationClick(_ sender: UIBarButtonItem) {
        chatTableView.isHidden = false
        groupsTableView.isHidden = true
    }
    
    //    func test() {
//        var result = [Chat]()
//        result.append(contentsOf: chats.sorted(by: { $0.timestamp > $1.timestamp }).filter({ chat in
//            if chat.to == firebaseAuth.currentUser?.uid {
//                return !result.contains(where: { $0.from == chat.from })
//            } else {
//                return !result.contains(where: { $0.to == chat.to })
//            }
//        }))
//    }
}

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCV", for: indexPath) as! OnlineFriendsCollectionViewCell
        
        cell.friendImage.kf.setImage(with: URL(string: usersArray[indexPath.row].profilePhoto ?? ""), placeholder: UIImage(named: "placeholder"), options: [])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedIndex = indexPath.item
        performSegue(withIdentifier: "toDetails", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 38, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == groupsTableView {
            return groupsArray.count
        }
        else {
            return nbRows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == chatTableView {
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "cellTV", for: indexPath) as! ChatTableViewCell
            
            cell.userImage.image = UIImage(named: imagesArray[indexPath.row])
            cell.userName.text = namesArray[indexPath.row]
            cell.messageText.text = lastMessage[indexPath.row]
            
            return cell
        }
        else {
            let cell = groupsTableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath) as! CharGroupTableViewCell
            
            cell.groupName.text = groupsArray[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == chatTableView {
            return 66
        }
        else {
            return 90
        }
    }
    
    // Set the spacing between the tableview and his header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == chatTableView {
            performSegue(withIdentifier: "toDetails", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            if let detailsVC = segue.destination as? DetailsChatViewController {
                detailsVC.passedUser = usersArray[selectedIndex]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let askAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            // delete function here...
            self.nbRows -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        // Here set your image and background color
        askAction.image = UIImage(systemName: "trash.fill")
        askAction.backgroundColor = .customGreen
        
        return UISwipeActionsConfiguration(actions: [askAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let askAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            // delete function here...
            self.nbRows -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }

        // Here set your image and background color
        askAction.image = UIImage(systemName: "trash.fill")
        askAction.backgroundColor = .customGreen
        
        return UISwipeActionsConfiguration(actions: [askAction])
    }
}
