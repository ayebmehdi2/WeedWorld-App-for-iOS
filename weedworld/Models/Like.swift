//
//  Like.swift
//  weedworld
//
//  Created by Fares Ben amor on 2/3/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class Like: Codable {
    var postId: String?
    var userId: String?
    
    init(postId: String?, userId: String?) {
        self.postId = postId
        self.userId = userId
    }
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            let likesDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]

            Firestore.firestore().collection("Likes").document().setData(likesDict) { error in
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
    
    func delete(completion: @escaping (_ success: Bool) -> Void) {
        Firestore.firestore().collection("Likes")
            .whereField("userId", isEqualTo: self.userId ?? "")
            .whereField("postId", isEqualTo: self.postId ?? "")
            .getDocuments(completion: { (snapshot, error) in
            
            if let err = error {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                for document in snapshot!.documents {
                    // delete the document using the ID
                    Firestore.firestore().collection("Likes").document(document.documentID).delete()
                    completion(true)
                }
            }
        })
    }
}
