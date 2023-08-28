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

class LocalStore: Codable {
	var businessName: String?
	var businessNameLowercase: String?
	var businessType: String?
	var coverPhoto: String?
	var emailAddress: String?
	var geohash: String?
	var lat: Double?
	var licence: String?
	var streetName: String?
	var city: String?
	var lng: Double?
	var fromTime: String?
	var toTime: String?
	var phone: String?
	var photo: String?
	var timestamp: Timestamp?
	var userId: String?
	var website: String?
	var storeId: String?
    var deliveryFee: Double?
    var salesTax: Double?
    var stateTax: Double?
	
	// Constructor with storeId for getting
    init(businessName: String?, businessNameLowerCase: String?, businessType: String?, emailAdress: String?, geohash: String?, lat: Double?, license: String?, lng: Double?, streetName: String?, city: String?, phone: String?, photo: String?, coverPhoto: String?, userId: String?, website: String?, storeId: String?, fromTime: String?, toTime: String?, deliveryFee: Double?, salesTax: Double?, stateTax: Double?) {
		self.businessName = businessName
		self.businessNameLowercase = businessNameLowerCase
		self.businessType = businessType
		self.emailAddress = emailAdress
		self.geohash = geohash
		self.lat = lat
		self.licence = license
		self.lng = lng
		self.streetName = streetName
		self.fromTime = fromTime
		self.toTime = toTime
		self.city = city
		self.phone = phone
		self.photo = photo
		self.coverPhoto = coverPhoto
		self.userId = userId
		self.website = website
		self.storeId = storeId
        self.deliveryFee = deliveryFee
        self.stateTax = stateTax
        self.salesTax = salesTax
	}
	
	// Constructor without storeId for add only
	init(businessName: String?, businessNameLowerCase: String?, businessType: String?, emailAdress: String?, geohash: String?, lat: Double?, license: String?, lng: Double?, streetName: String?, city: String?, phone: String?, photo: String?, userId: String?, website: String?) {
		self.businessName = businessName
		self.businessNameLowercase = businessNameLowerCase
		self.businessType = businessType
		self.emailAddress = emailAdress
		self.geohash = geohash
		self.lat = lat
		self.licence = license
		self.lng = lng
		self.streetName = streetName
		self.city = city
		self.phone = phone
		self.photo = photo
		self.userId = userId
		self.website = website
	}
	
	func save(completion: @escaping (_ success: Bool) -> Void) {
		do {
			let jsonObject = try JSONEncoder().encode(self)
			var storeDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			storeDict.updateValue(FieldValue.serverTimestamp(), forKey: "timestamp")

			Firestore.firestore().collection("Store").document().setData(storeDict) { error in
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
