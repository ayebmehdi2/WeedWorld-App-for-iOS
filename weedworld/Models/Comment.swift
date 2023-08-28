//
//  Comment.swift
//  weedworld
//
//  Created by Fares Ben amor on 1/3/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class Comment: Codable {
    var content: String?
    var postId: String?
    var timestamp: Timestamp?
    var userId: String?
    
    init(content: String?, postId: String?, timestamp: Timestamp?, userId: String?) {
        self.content = content
        self.postId = postId
        self.timestamp = timestamp
        self.userId = userId
    }
    
    init(content: String?, postId: String?, userId: String?) {
        self.content = content
        self.postId = postId
        self.userId = userId
    }
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            var commentDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            commentDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")

            Firestore.firestore().collection("Comments").document().setData(commentDict) { error in
                guard let error = error else {
                    completion(true)
                    return
                }
                print("Error", error.localizedDescription)
                completion(false)
            }
        }
        catch let err {
            print("Error", err.localizedDescription)
            completion(false)
        }
    }
}
