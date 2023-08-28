//
//  Post.swift
//  weedworld
//
//  Created by Fares Ben amor on 31/1/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class Post: Codable {
    var userId: String?
    var text: String?
    var image: String?
    var aspectRatio: Float?
    var isPrivate: Bool?
    var timestamp: Timestamp?
    var likes: [String]? = []
    var comments: [String]? = []
    var postId: String?
	var storeId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case text
        case image
        case aspectRatio
        case isPrivate = "private"
        case timestamp
        case likes
        case comments
		case storeId
    }
    
    init() {
        
    }
    
    init(userId: String?, text: String?, image: String?, aspectRatio: Float?, isPrivate: Bool?) {
        self.userId = userId
        self.text = text
        self.image = image
        self.aspectRatio = aspectRatio
        self.isPrivate = isPrivate
    }
    
    init(userId: String?, text: String?, image: String?, aspectRatio: Float?, isPrivate: Bool?, timestamp: Timestamp?, comments: [String]?, likes: [String]?, postId: String?) {
        self.userId = userId
        self.text = text
        self.image = image
        self.aspectRatio = aspectRatio
        self.isPrivate = isPrivate
        self.timestamp = timestamp
        self.comments = comments
        self.likes = likes
        self.postId = postId
    }
	
	// With storeId
	init(userId: String?, text: String?, image: String?, aspectRatio: Float?, isPrivate: Bool?, storeId: String) {
		self.userId = userId
		self.text = text
		self.image = image
		self.aspectRatio = aspectRatio
		self.isPrivate = isPrivate
		self.storeId = storeId
	}
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            var postDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            postDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
            
            Firestore.firestore().collection("Posts_m").document().setData(postDict) { error in
                guard let error = error else {
                    completion(true)
                    return
                }
                print("Errooor", error.localizedDescription)
                completion(false)
            }
        }
        catch let err {
            print("Error", err.localizedDescription)
            completion(false)
        }
    }
}
