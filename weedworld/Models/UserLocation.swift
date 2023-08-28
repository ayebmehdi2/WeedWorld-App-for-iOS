//
//  UserLocation.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 16/04/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserLocation: Codable {
	var geohash: String?
	var lat: Double?
	var lng: Double?
	var timestamp: Timestamp?
	var userId: String?
	
	init(geohash: String?, lat: Double?, lng: Double?, userId: String?) {
		self.geohash = geohash
		self.lat = lat
		self.lng = lng
		self.userId = userId
	}
	
	func save() async throws -> Bool {
		do {
			let db = Firestore.firestore().collection("UserLocation")
			let jsonObject = try JSONEncoder().encode(self)
			var storeDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			storeDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
			
			try await db.document().setData(storeDict)
			
			return true
			
		} catch let err {
			print("Error", err.localizedDescription)
			return false
		}
	}
	
	func update(documentID: String) async throws -> Bool {
		do {
			let db = Firestore.firestore().collection("UserLocation")
			let jsonObject = try JSONEncoder().encode(self)
			var storeDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			storeDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
			
			try await db.document(documentID).updateData(storeDict)
			
			return true
			
		} catch let err {
			print("Error", err.localizedDescription)
			return false
		}
	}
}
