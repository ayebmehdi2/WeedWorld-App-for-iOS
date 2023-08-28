//
//  StoreRegistration.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 04/04/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class StoreRegistration: Codable {
	var businessName: String?
	var businessType: String?
	var city: String?
	var emailAdress: String?
	var license: String?
	var licensePDF: String?
	var phone: String?
	var streetName: String?
	var timestamp: Timestamp?
	var useFor: String?
	var userId: String?
	var website: String?
		
	// OnlineStore with PDF
	init(businessName: String?, businessType: String?, emailAdress: String?, license: String?, licensePDF: String?, phone: String?, useFor: String?, userId: String?, website: String?) {
		self.businessName = businessName
		self.businessType = businessType
		self.emailAdress = emailAdress
		self.license = license
		self.licensePDF = licensePDF
		self.phone = phone
		self.useFor = useFor
		self.userId = userId
		self.website = website
	}
	
	// OnlineStore without PDF
	init(businessName: String?, businessType: String?, emailAdress: String?, license: String?, phone: String?, userId: String?, website: String?) {
		self.businessName = businessName
		self.businessType = businessType
		self.emailAdress = emailAdress
		self.license = license
		self.phone = phone
		self.userId = userId
		self.website = website
	}
	
	// LocalStore with PDF
	init(businessName: String?, businessType: String?, city: String?, emailAdress: String?, license: String?, licensePDF: String?, phone: String?, streetName: String?, useFor: String?, userId: String?, website: String?) {
		self.businessName = businessName
		self.businessType = businessType
		self.city = city
		self.emailAdress = emailAdress
		self.license = license
		self.licensePDF = licensePDF
		self.phone = phone
		self.streetName = streetName
		self.useFor = useFor
		self.userId = userId
		self.website = website
	}
	
	// LocalStore without PDF
	init(businessName: String?, businessType: String?, city: String?, emailAdress: String?, license: String?, phone: String?, streetName: String?, userId: String?, website: String?) {
		self.businessName = businessName
		self.businessType = businessType
		self.city = city
		self.emailAdress = emailAdress
		self.license = license
		self.phone = phone
		self.streetName = streetName
		self.userId = userId
		self.website = website
	}
	
	func saveResgistration(completion: @escaping (_ success: Bool) -> Void) {
		do {
			let jsonObject = try JSONEncoder().encode(self)
			var commentDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			commentDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
			
			Firestore.firestore().collection("StoreRegistration").document().setData(commentDict) { error in
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
	
	func saveStoreOnly(completion: @escaping (_ success: Bool) -> Void) {
		do {
			let jsonObject = try JSONEncoder().encode(self)
			var commentDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			commentDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")
			
			Firestore.firestore().collection("Store").document().setData(commentDict) { error in
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
