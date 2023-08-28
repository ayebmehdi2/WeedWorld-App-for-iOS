//
//  Product.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 21/05/2023.
//

import Foundation
import UIKit
import Firebase

class Product: Codable {
	var brand: String?
	var category: String?
	var cbd: Float?
	var description: String?
	var discountPrice: Double?
	var images: [String]? = []
	var name: String?
	var nameLowerCase: String?
	var price: Double?
	var storeId: String?
	var thc: Float?
	var timestamp: Timestamp?
	var weight: Float?
	var productId: String?
	var quantity: Int?
	
	init(brand: String?, category: String?, cbd: Float?, description: String?, discountPrice: Double?, images: [String]?, name: String?, nameLowerCase: String?, price: Double?, storeId: String?, thc: Float?, weight: Float?, productId: String?) {
		self.brand = brand
		self.category = category
		self.cbd = cbd
		self.description = description
		self.discountPrice = discountPrice
		self.images = images
		self.name = name
		self.nameLowerCase = nameLowerCase
		self.price = price
		self.storeId = storeId
		self.thc = thc
		self.weight = weight
		self.productId = productId
	}
}
