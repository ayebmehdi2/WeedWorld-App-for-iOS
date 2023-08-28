//
//  DetailsChatViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 24/2/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

class DetailsChatViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var encryptView: UIView! {
        didSet {
            encryptView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var emojisCollectionView: UICollectionView!
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var passedImage: String = ""
    var passedName = ""
    var selectedEmojiIndex: Int?
    var passedUser: User?
    var messagesArray: [Message] = [] {
        didSet {
			let indexPath = IndexPath(row: messagesArray.count - 1, section: 0)
            chatTableView.reloadData()
			chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    let emojisArray = ["emoji_0", "emoji_1", "emoji_2", "emoji_3", "emoji_4", "emoji_5", "emoji_6", "emoji_7", "emoji_8", "emoji_9", "emoji_10", "emoji_11", "emoji_12", "emoji_13", "emoji_14", "emoji_15", "emoji_16", "emoji_17", "emoji_18", "emoji_19", "emoji_20", "emoji_21", "emoji_22", "emoji_23", "emoji_24", "emoji_25", "emoji_26", "emoji_27", "emoji_28", "emoji_29", "emoji_30", "emoji_31", "emoji_32"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTitleView2()
        createSendButton()
        addNotificationObservers()
        Task {
            await getMessages()
        }
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let tabbarHeight = tabBarController?.tabBar.frame.height
            if messageTF.isFirstResponder {
				if view.frame.origin.y == 0 {
					view.frame.origin.y -= keyboardSize.height - (tabbarHeight ?? 0)
				}
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if messageTF.isFirstResponder {
			view.frame.origin.y = 0
        }
    }
    
    func setupUI() {
        chatTableView.contentInset.top = 10
        chatTableView.register(UINib(nibName: "ReceiverTableViewCell", bundle: nil), forCellReuseIdentifier: "receiverCell")
        chatTableView.register(UINib(nibName: "SenderTableViewCell", bundle: nil), forCellReuseIdentifier: "senderCell")
    }
    
//    func getMessages() {
//        showActivityIndicator(view: view, activityIndicator: activityIndicator)
//        FirebaseHelper.getHistoricMessages(uid: "Zabdet3YbYXY27azEHLrDVml4192", friendUid: "CCgBoM6P27Mg9kEkQFcAl2Wxwcr1", completion: { messages in
//            guard let messages = messages else {
//                self.showAlert(title: "Error", message: "An error occured, try later.")
//                return
//            }
//            self.messagesArray = messages
//            self.stopActivityIndicator(activityIndicator: self.activityIndicator)
//        })
//    }
    
    func getMessages() async {
        showActivityIndicator(view: view, activityIndicator: activityIndicator)
        do {
            let (query1Messages, query2Messages) = try await FirebaseHelper.getHistoricMessages2(uid: "Zabdet3YbYXY27azEHLrDVml4192", friendUid: "CCgBoM6P27Mg9kEkQFcAl2Wxwcr1")

            messagesArray.append(contentsOf: query1Messages)
            messagesArray.append(contentsOf: query2Messages)
            stopActivityIndicator(activityIndicator: activityIndicator)

        } catch let errr {
            print("Error fetching data: \(errr)")
        }
    }
    
    func setupTitleView2() {
        let contentView = UIView()
        let greenDot = UIView()
        let imageView = UIImageView()
        let userName = UILabel()
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 150),
            contentView.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        // imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let image = passedUser?.profilePhoto {
            imageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"), options: [])
        }
        //imageView.image = UIImage(named: "messi")
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 26),
            imageView.heightAnchor.constraint(equalToConstant: 26),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
        
        // greenDot
        greenDot.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(greenDot)
        NSLayoutConstraint.activate([
            greenDot.widthAnchor.constraint(equalToConstant: 10),
            greenDot.heightAnchor.constraint(equalToConstant: 10),
            greenDot.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            greenDot.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        greenDot.backgroundColor = .systemGreen
        greenDot.layer.cornerRadius = 5
        
        // nameLabel
        userName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userName)
        NSLayoutConstraint.activate([
            userName.heightAnchor.constraint(equalToConstant: 25),
            userName.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        userName.font = UIFont(name: "Poppins-Medium", size: 15)
        userName.text = passedUser?.username
        
        navigationItem.titleView = contentView
    }
    
    func createSendButton() {
        let sendBtn = UIButton(type: .system)
        view.addSubview(sendBtn)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendBtn.trailingAnchor.constraint(equalTo: messageTF.trailingAnchor, constant: -10),
            sendBtn.widthAnchor.constraint(equalToConstant: 20),
            sendBtn.heightAnchor.constraint(equalToConstant: 20),
            sendBtn.centerYAnchor.constraint(equalTo: messageTF.centerYAnchor)
        ])
        sendBtn.setTitle("", for: .normal)
        sendBtn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendBtn.tintColor = .darkGray
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func sendMessage() {
        if messageTF.text != "" || selectedEmojiIndex != nil {
            let message = Message.init(content: messageTF.text, emoji: selectedEmojiIndex, from: "VrxzzyeKsHdkVEn5kV5PILQIF3F2", to: "Zabdet3YbYXY27azEHLrDVml4192")
            messageTF.text = ""
            message.save(completion: { success in
                if success {
                    print("success")
                    self.messagesArray.append(message)
                    self.chatTableView.reloadData()
                    self.scrollToBottom()
                }
                else {
                    self.showAlert(title: "Error", message: "An error has occured.")
                }
            })
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messagesArray.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func groupBtnClick(_ sender: UIBarButtonItem) {
        let popup = AddGroupViewController(nibName: "AddGroupViewController", bundle: nil)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.passedUserUID = self.passedUser?.uid ?? ""
        self.present(popup, animated: true)
    }
    
    @IBAction func emojiClick(_ sender: UITapGestureRecognizer) {
        emojisCollectionView.isHidden.toggle()
    }
}

extension DetailsChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let textWidth = messagesArray[indexPath.row].content?.size(withAttributes: [.font : UIFont(name: "Poppins-Regular", size: 14)!]).width
        let paddingStack: CGFloat = 10
        let imageWidth: CGFloat = 25
        let labelPadding: CGFloat = 20
        let totalPadding = paddingStack + imageWidth + labelPadding

        if messagesArray[indexPath.row].from == "VrxzzyeKsHdkVEn5kV5PILQIF3F2" {
            let cellReceiver = chatTableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as! ReceiverTableViewCell

            cellReceiver.texteReceiver.text = messagesArray[indexPath.row].content
            cellReceiver.imageReceiver.image = UIImage(named: "ronaldo")

            if let emojiIndex = messagesArray[indexPath.row].emoji {
                cellReceiver.emojiReveiver.image = UIImage(named: emojisArray[emojiIndex])
                cellReceiver.contentStackWidth.constant = 150
                cellReceiver.bubleViewReceiver.isHidden = true
                cellReceiver.emojiReveiver.isHidden = false
            }
            else {
                cellReceiver.bubleViewReceiver.isHidden = false
                cellReceiver.emojiReveiver.isHidden = true

                if (textWidth ?? 0) + totalPadding <= 250 {
                    cellReceiver.contentStackWidth.constant = (textWidth ?? 0) + totalPadding + 5
                }
                else {
                    cellReceiver.contentStackWidth.constant = 250
                }
            }

            return cellReceiver
        }
        else {
            let cellSender = chatTableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! SenderTableViewCell

            cellSender.textSender.text = messagesArray[indexPath.row].content
            cellSender.imageSender.image = UIImage(named: "messi")

            if let emojiIndex = messagesArray[indexPath.row].emoji {
                cellSender.emojiSender.image = UIImage(named: emojisArray[emojiIndex])
                cellSender.contentSenderStackWidth.constant = 150
                cellSender.bubleViewSender.isHidden = true
                cellSender.emojiSender.isHidden = false
            }
            else {
                cellSender.bubleViewSender.isHidden = false
                cellSender.emojiSender.isHidden = true

                if (textWidth ?? 0) + totalPadding <= 250 {
                    cellSender.contentSenderStackWidth.constant = (textWidth ?? 0) + totalPadding + 5
                }
                else {
                    cellSender.contentSenderStackWidth.constant = 250
                }
            }

            return cellSender
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = messagesArray[indexPath.row].emoji {
            return 100
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension DetailsChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojisArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EmojiCollectionViewCell
        
        cell.emojiImage.image = UIImage(named: emojisArray[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmojiIndex = indexPath.item
        sendMessage()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
}
