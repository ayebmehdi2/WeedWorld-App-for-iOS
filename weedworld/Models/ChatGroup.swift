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

class ChatGroup: Codable {
    var name: String?
    var to: [String]? = []
    var userId: String?
    
    init(name: String?, to: [String]?, userId: String?) {
        self.name = name
        self.to = to
        self.userId = userId
    }
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            let chatDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]

            Firestore.firestore().collection("ChatGroup").document().setData(chatDict) { error in
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
