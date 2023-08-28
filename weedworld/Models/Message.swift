//
//  Message.swift
//  weedworld
//
//  Created by Fares Ben amor on 26/2/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class Message: Codable {
    var content: String?
    var emoji: Int?
    var from: String?
    var timestamp: Timestamp?
    var to: String?
    
    init(content: String?, emoji: Int?, from: String?, to: String?) {
        self.content = content
        self.emoji = emoji
        self.from = from
        self.to = to
    }
    
    init(content: String?, emoji: Int?, from: String?, timestamp: Timestamp?, to: String?) {
        self.content = content
        self.emoji = emoji
        self.from = from
        self.timestamp = timestamp
        self.to = to
    }
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            var messageDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            messageDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")

            Firestore.firestore().collection("Chat").document().setData(messageDict) { error in
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
