//
//  Order.swift
//  weedworld
//
//  Created by Mac on 13/7/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Order: Codable {
    var storeId: String?
    var storeName: String?
    var products: [String?]?
    var userId: String?
    var orderTotal: String?
    var firstName: String?
    var lastName: String?
    var mobileNumber: String?
    var deliveryMode: Int?
    var deliveryStatus: Int? = 0
    var deliverAddress: String?
    var timestamp: Timestamp?
    var qrCode: String?
    var orderId: String?

    
    func saveOrder(completion: @escaping (_ success: Bool) -> Void) {
        do {
            let jsonObject = try JSONEncoder().encode(self)
            var commentDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            commentDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
            
            Firestore.firestore().collection("Order").document().setData(commentDict) { error in
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
