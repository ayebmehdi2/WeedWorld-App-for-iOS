//
//  User.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class User: Codable {
    
    var uid: String = ""
    var username: String = ""
    var email: String = ""
    var phone: String = ""
    var birthday: String = ""
    var gender: String = ""
    var profilePhoto: String?
    var coverPhoto: String?
    
    init(uid: String, username: String, email: String, phone: String, birthday: String, gender: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.phone = phone
        self.birthday = birthday
        self.gender = gender
    }
    
    init(uid: String, username: String, email: String, phone: String, birthday: String, gender: String, profilePhoto: String, coverPhoto: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.phone = phone
        self.birthday = birthday
        self.gender = gender
        self.coverPhoto = coverPhoto
        self.profilePhoto = profilePhoto
    }
    
    func save(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            let userDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            
            Database.database().reference().child("Users").child(self.uid).setValue(userDict) { (err, ref) in
                
                if (err == nil) {
                    completion(true)
                }
                else {
                    print("Error", err!.localizedDescription)
                    completion(false)
                }
            }
        }
        catch let err {
            print("Error", err.localizedDescription)
            completion(false)
        }
    }
}
