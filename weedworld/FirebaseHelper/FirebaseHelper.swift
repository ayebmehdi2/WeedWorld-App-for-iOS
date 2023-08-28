//
//  FirebaseHelper.swift
//  weedworld
//
//  Created by Fares Ben amor on 1/2/2023.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GeoFire

class FirebaseHelper {
    
    static func getUserByUID(uid: String, completion: @escaping (_ user: User?) -> Void) {
        let refPoint = Database.database().reference(withPath: "Users")
        refPoint.child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let snap = snapshot.value {
                do {
                    let json = try JSONSerialization.data(withJSONObject: snap)
                    let model = try JSONDecoder().decode(User.self, from: json)
                    completion(model)
                }
                catch let parsingError {
                    print("Error", parsingError)
                }
            }
        })
    }
    
    static func getAllPosts(completion: @escaping (_ posts: [Post]?) -> Void) {
        Firestore.firestore().collection("Posts_m").addSnapshotListener({ (snapshot, error) in
            if let error = error {
                print("Erroor", error)
                completion(nil)
            } else if let snapshot = snapshot {
                var postsArray: [Post] = []
                
                for snapp in snapshot.documents {
                    let data = snapp.data()
                    
                    // Object
                    let userId = data["userId"] as? String
                    let aspectRatio = data["aspectRatio"] as? Float
                    let image = data["image"] as? String
                    let isPrivate = data["private"] as? Bool
                    let text = data["text"] as? String
                    let comments = data["comments"] as? [String]
                    let likes = data["likes"] as? [String]
                    let time = data["timestamp"] as? FirebaseFirestore.Timestamp
                    
                    let post = Post.init(userId: userId, text: text, image: image, aspectRatio: aspectRatio, isPrivate: isPrivate, timestamp: time, comments: comments, likes: likes, postId: snapp.documentID)
                    postsArray.append(post)
                }
                completion(postsArray)
            }
        })
    }
    
    static func getPostsByUID(uid: String, completion: @escaping (_ posts: [Post]?) -> Void) {
        let query = Firestore.firestore().collection("Posts_m").whereField("userId", isEqualTo: uid)
        query.getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print("Erroor", error)
                completion(nil)
            } else if let snapshot = snapshot {
                var postsArray: [Post] = []
                
                for snapp in snapshot.documents {
                    let data = snapp.data()
                    
                    // Object
                    let userId = data["userId"] as? String
                    let aspectRatio = data["aspectRatio"] as? Float
                    let image = data["image"] as? String
                    let isPrivate = data["private"] as? Bool
                    let text = data["text"] as? String
                    let comments = data["comments"] as? [String]
                    let likes = data["likes"] as? [String]
                    let time = data["timestamp"] as? FirebaseFirestore.Timestamp
                    
                    let post = Post.init(userId: userId, text: text, image: image, aspectRatio: aspectRatio, isPrivate: isPrivate, timestamp: time, comments: comments, likes: likes, postId: snapp.documentID)
                    postsArray.append(post)
                }
                completion(postsArray)
            }
        })
    }
	
	static func getPostsByStoreId(storeId: String) async throws -> [Post]? {
		let query = Firestore.firestore().collection("Posts_m").whereField("storeId", isEqualTo: storeId)
		var posts: [Post] = []
		
		do {
			let snapshot = try await query.getDocuments()

			for snapp in snapshot.documents {
				let data = snapp.data()
				
				// Object
				let userId = data["userId"] as? String
				let aspectRatio = data["aspectRatio"] as? Float
				let image = data["image"] as? String
				let isPrivate = data["private"] as? Bool
				let text = data["text"] as? String
				let comments = data["comments"] as? [String]
				let likes = data["likes"] as? [String]
				let time = data["timestamp"] as? FirebaseFirestore.Timestamp
				
				let post = Post.init(userId: userId, text: text, image: image, aspectRatio: aspectRatio, isPrivate: isPrivate, timestamp: time, comments: comments, likes: likes, postId: snapp.documentID)
				posts.append(post)
			}
				
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return posts
	}
    
    static func updateUserPhotos(profilePhoto: String? = nil, coverPhoto: String? = nil, completion: @escaping (_ success: Bool) -> Void) {
        
        var dict: [String: Any] = [:]
        
        if let profilePhoto = profilePhoto {
            dict.updateValue(profilePhoto, forKey: "profilePhoto")
        }
        
        if let coverPhoto = coverPhoto {
            dict.updateValue(coverPhoto, forKey: "coverPhoto")
        }
        
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(dict, withCompletionBlock: { (err , ref) in
            
            if (err == nil) {
                completion(true)
            }
            else {
                print("Error", err!.localizedDescription)
                completion(false)
            }
        })
    }
    
    static func getHistoricMessages(uid: String, friendUid: String, completion: @escaping (_ messages: [Message]?) -> Void) {
        
        Firestore.firestore().collection("Chat")
            .whereField("from", in: [uid, friendUid])
            .addSnapshotListener({ (snapshot, error) in
                
                if let error = error {
                    print("Erroor", error)
                    completion(nil)
                } else if let snapshot = snapshot {
                    var messagesArray: [Message] = []

                    for snapp in snapshot.documents {
                        let data = snapp.data()

                        // Object
                        let content = data["content"] as? String
                        let emoji = data["emoji"] as? Int
                        let from = data["from"] as? String
                        let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                        let to = data["to"] as? String

                        let message = Message.init(content: content, emoji: emoji, from: from, timestamp: timestamp, to: to)
                        messagesArray.append(message)
                    }
                    completion(messagesArray)
                }
            })
    }
    
    static func getHistoricMessages2(uid: String, friendUid: String) async throws -> ([Message], [Message]) {
        let db = Firestore.firestore()
        let query1 = db.collection("Chat").whereField("from", in: [uid, friendUid])
        let query2 = db.collection("Chat").whereField("to", in: [uid, friendUid])
        
        var messageArray1: [Message] = []
        var messageArray2: [Message] = []
        
        do {
            let query1Snapshot = try await query1.getDocuments()
            let query2Snapshot = try await query2.getDocuments()
            
            for document in query1Snapshot.documents {
                let data = document.data()

                // Object
                let content = data["content"] as? String
                let emoji = data["emoji"] as? Int
                let from = data["from"] as? String
                let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                let to = data["to"] as? String

                let message = Message.init(content: content, emoji: emoji, from: from, timestamp: timestamp, to: to)
                messageArray1.append(message)
            }

            for document in query2Snapshot.documents {
                let data = document.data()

                // Object
                let content = data["content"] as? String
                let emoji = data["emoji"] as? Int
                let from = data["from"] as? String
                let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                let to = data["to"] as? String

                let message = Message.init(content: content, emoji: emoji, from: from, timestamp: timestamp, to: to)
                messageArray2.append(message)
            }

        } catch let err {
            print("Error fetching data: \(err)")
        }
        return (messageArray1, messageArray2)
    }
    
    static func getDiscussions(uid: String, friendUid: String) async throws -> ([Message], [Message]) {
        let db = Firestore.firestore()
        let query1 = db.collection("Chat").whereField("from", in: [uid, friendUid])
        let query2 = db.collection("Chat").whereField("to", in: [uid, friendUid])
        
        var messageArray1: [Message] = []
        var messageArray2: [Message] = []
        
        do {
            let query1Snapshot = try await query1.getDocuments()
            let query2Snapshot = try await query2.getDocuments()
            
            for document in query1Snapshot.documents {
                let data = document.data()

                // Object
                let content = data["content"] as? String
                let emoji = data["emoji"] as? Int
                let from = data["from"] as? String
                let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                let to = data["to"] as? String

                let message = Message.init(content: content, emoji: emoji, from: from, timestamp: timestamp, to: to)
                messageArray1.append(message)
            }

            for document in query2Snapshot.documents {
                let data = document.data()

                // Object
                let content = data["content"] as? String
                let emoji = data["emoji"] as? Int
                let from = data["from"] as? String
                let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                let to = data["to"] as? String

                let message = Message.init(content: content, emoji: emoji, from: from, timestamp: timestamp, to: to)
                messageArray2.append(message)
            }

        } catch let erro {
            print("Error fetching data: \(erro)")
        }
        return (messageArray1, messageArray2)
    }
    
    static func getPostComments(postId: String, completion: @escaping (_ comments: [Comment]?) -> Void) {
        Firestore.firestore().collection("Comments")
            .whereField("postId", isEqualTo: postId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                print("Erroor", error)
                completion(nil)
            } else if let snapshot = snapshot {
                
                var commentsArray: [Comment] = []
                
                for snapp in snapshot.documents {
                    let data = snapp.data()
                    
                    // Object
                    let content = data["content"] as? String
                    let postId = data["postId"] as? String
                    let timestamp = data["timestamp"] as? FirebaseFirestore.Timestamp
                    let userId = data["userId"] as? String
                    
                    let comment = Comment.init(content: content, postId: postId, timestamp: timestamp, userId: userId)
                    commentsArray.append(comment)
                }
                completion(commentsArray)
            }
        })
    }
    
    static func getPostLikes(postId: String, completion: @escaping (_ likes: [Like]?) -> Void) {
        Firestore.firestore().collection("Likes")
            .whereField("postId", isEqualTo: postId)
            .addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                print("Erroor", error)
                completion(nil)
            } else if let snapshot = snapshot {
                
                var likesArray: [Like] = []
                
                for snapp in snapshot.documents {
                    let data = snapp.data()
                    
                    // Object
                    let postId = data["postId"] as? String
                    let userId = data["userId"] as? String
                    
                    let like = Like.init(postId: postId, userId: userId)
                    likesArray.append(like)
                }
                completion(likesArray)
            }
        })
    }
    
    static func deletePost(postId: String, completion: @escaping (_ succes: Bool) -> Void) {
        Firestore.firestore().collection("Posts_m").document(postId).delete(completion: { error in
            if let err = error {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    static func editPost(postId: String, text: String, completion: @escaping (_ succes: Bool) -> Void) {
        Firestore.firestore().collection("Posts_m").document(postId).updateData(["text" : text], completion: { error in
            if let err = error {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    static func getOnlineUsers(completion: @escaping (_ usersUids: [String]?) -> Void) {
        Firestore.firestore().collection("Status")
            .whereField("userId", isNotEqualTo: Auth.auth().currentUser!.uid)
            .addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
				print("Erroor", error.localizedDescription)
                completion(nil)
            } else if let snapshot = snapshot {
                
                var usersUids: [String] = []

                for snapp in snapshot.documents {
                    let data = snapp.data()
                    if let userId = data["userId"] as? String {
                        usersUids.append(userId)
                    }
                }
                completion(usersUids)
            }
        })
    }
    
    static func getUserChatGroups(uid: String, completion: @escaping (_ names: [String]?) -> Void) {
        Firestore.firestore().collection("ChatGroup")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener({ (snapshot, error) in
                
                if let error = error {
					print("Erroor", error.localizedDescription)
                    completion(nil)
                } else if let snapshot = snapshot {
                    
                    var names: [String] = []

                    for snapp in snapshot.documents {
                        let data = snapp.data()
                        if let name = data["name"] as? String {
                            names.append(name)
                        }
                    }
                    completion(names)
                }
            })
    }
	
	static func updateNearbyPosition(userLat: CLLocationDegrees, userLong: CLLocationDegrees) async throws -> Bool {
		let db = Firestore.firestore().collection("UserLocation")
		let location = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
		let geoHash = GFUtils.geoHash(forLocation: location)
		
		do {
			let document = try await db.whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments()
			
			let userLocation = UserLocation(geohash: geoHash, lat: userLat, lng: userLong, userId: Auth.auth().currentUser!.uid)
			
			if document.isEmpty {
				let saveResult = try await userLocation.save()
				return saveResult
			}
			else {
				if let documentID = document.documents.first?.documentID {
					let updateRes = try await userLocation.update(documentID: documentID)
					return updateRes
				}
				else {
					return false
				}
			}
			
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return false
		}
	}
	
	static func getNearbyUsers(userLat: CLLocationDegrees, userLong: CLLocationDegrees, radius: Double) async throws -> [UserLocation]? {
		let db = Firestore.firestore().collection("UserLocation")
		let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
		let radiusInM: Double = radius * 1000
		
		let queryBound = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
		var users: [UserLocation] = []
		
		for bound in queryBound {
			let query2 = db
				.order(by: "geohash")
				.start(at: [bound.startValue])
				.end(at: [bound.endValue])
			
			do {
				let snapshot = try await query2.getDocuments()
				
				for snapp in snapshot.documents {
					let data = snapp.data()
					
					let userId = data["userId"] as? String
					if userId != Auth.auth().currentUser!.uid {
						let geohash = data["geohash"] as? String
						let lat = data["lat"] as? Double
						let lng = data["lng"] as? Double
						
						let user = UserLocation.init(geohash: geohash, lat: lat, lng: lng, userId: userId)
						users.append(user)
					}
				}
				
			} catch let err {
				print("Error fetching data: \(err.localizedDescription)")
				return nil
			}
		}
		return users
	}
	
	static func getNearbyStores(userLat: CLLocationDegrees, userLong: CLLocationDegrees, radius: Double) async throws -> [LocalStore] {
		// Find stores within 50km of user location
		let db = Firestore.firestore().collection("Store")
		let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
		let radiusInM: Double = radius * 1000
		
		let queryBound = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
		var stores: [LocalStore] = []

		for bound in queryBound {
			let query2 = db
				.order(by: "geohash")
				.start(at: [bound.startValue])
				.end(at: [bound.endValue])
			
			do {
				let snapshot = try await query2.getDocuments()
				
				for snapp in snapshot.documents {
					let data = snapp.data()
					
					// Object
					let businessName = data["businessName"] as? String
					let businessNameLowerCase = data["businessNameLowercase"] as? String
					let businessType = data["businessType"] as? String
					let emailAdress = data["emailAddress"] as? String
					let geohash = data["geohash"] as? String
					let lat = data["lat"] as? Double
					let license = data["licence"] as? String
					let lng = data["lng"] as? Double
					let streetName = data["streetName"] as? String
					let fromTime = data["fromTime"] as? String
					let toTime = data["toTime"] as? String
					let city = data["city"] as? String
					let phone = data["phone"] as? String
					let photo = data["photo"] as? String
					let coverPhoto = data["coverPhoto"] as? String
					let website = data["website"] as? String
					let userId = data["userId"] as? String
                    let deliveryFee = data["deliveryFee"] as? Double
                    let stateTax = data["stateTax"] as? Double
                    let salesTax = data["salesTax"] as? Double

					let store = LocalStore.init(businessName: businessName, businessNameLowerCase: businessNameLowerCase, businessType: businessType, emailAdress: emailAdress, geohash: geohash, lat: lat, license: license, lng: lng, streetName: streetName, city: city, phone: phone, photo: photo, coverPhoto: coverPhoto, userId: userId, website: website, storeId: snapp.documentID, fromTime: fromTime, toTime: toTime, deliveryFee: deliveryFee, salesTax: salesTax, stateTax: stateTax)
					
					stores.append(store)
				}
			} catch let err {
				print("Error fetching data: \(err.localizedDescription)")
			}
		}
		return stores
	}
	
    static func getStoreByUserId(uid: String? = Auth.auth().currentUser?.uid) async throws -> [LocalStore]? {
        guard let uid = uid else { return nil }
		let db = Firestore.firestore().collection("Store")
		var stores: [LocalStore] = []
		
		do {
			let snapshot = try await db.whereField("userId", isEqualTo: uid).getDocuments()
			
			for snapp in snapshot.documents {
				let data = snapp.data()
				
				// Object
				let businessName = data["businessName"] as? String
				let businessNameLowerCase = data["businessNameLowercase"] as? String
				let businessType = data["businessType"] as? String
				let emailAdress = data["emailAddress"] as? String
				let geohash = data["geohash"] as? String
				let lat = data["lat"] as? Double
				let license = data["licence"] as? String
				let lng = data["lng"] as? Double
				let streetName = data["streetName"] as? String
				let fromTime = data["fromTime"] as? String
				let toTime = data["toTime"] as? String
				let city = data["city"] as? String
				let phone = data["phone"] as? String
				let photo = data["photo"] as? String
				let coverPhoto = data["coverPhoto"] as? String
				let website = data["website"] as? String
				let userId = data["userId"] as? String
                let deliveryFee = data["deliveryFee"] as? Double
                let stateTax = data["stateTax"] as? Double
                let salesTax = data["salesTax"] as? Double
				
				let store = LocalStore(businessName: businessName, businessNameLowerCase: businessNameLowerCase, businessType: businessType, emailAdress: emailAdress, geohash: geohash, lat: lat, license: license, lng: lng, streetName: streetName, city: city, phone: phone, photo: photo, coverPhoto: coverPhoto, userId: userId, website: website, storeId: snapp.documentID, fromTime: fromTime, toTime: toTime, deliveryFee: deliveryFee, salesTax: salesTax, stateTax: stateTax)
				
				stores.append(store)
			}
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return stores
	}
	
	static func getStoreByStoreId(storeId: String) async throws -> LocalStore? {
		let db = Firestore.firestore().collection("Store")
		
		do {
			let snapshot = try await db.document(storeId).getDocument()
			let data = snapshot.data()
			
			// Object
			let businessName = data?["businessName"] as? String
			let businessNameLowerCase = data?["businessNameLowercase"] as? String
			let businessType = data?["businessType"] as? String
			let emailAdress = data?["emailAddress"] as? String
			let geohash = data?["geohash"] as? String
			let lat = data?["lat"] as? Double
			let license = data?["licence"] as? String
			let lng = data?["lng"] as? Double
			let streetName = data?["streetName"] as? String
			let fromTime = data?["fromTime"] as? String
			let toTime = data?["toTime"] as? String
			let city = data?["city"] as? String
			let phone = data?["phone"] as? String
			let photo = data?["photo"] as? String
			let coverPhoto = data?["coverPhoto"] as? String
			let website = data?["website"] as? String
			let userId = data?["userId"] as? String
            let deliveryFee = data?["deliveryFee"] as? Double
            let stateTax = data?["stateTax"] as? Double
            let salesTax = data?["salesTax"] as? Double
			
			let store = LocalStore(businessName: businessName, businessNameLowerCase: businessNameLowerCase, businessType: businessType, emailAdress: emailAdress, geohash: geohash, lat: lat, license: license, lng: lng, streetName: streetName, city: city, phone: phone, photo: photo, coverPhoto: coverPhoto, userId: userId, website: website, storeId: snapshot.documentID, fromTime: fromTime, toTime: toTime, deliveryFee: deliveryFee, salesTax: salesTax, stateTax: stateTax)
			return store
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
	}
	
	static func getItemsByStoreId(storeId: String) async throws -> [Product]? {
		let db = Firestore.firestore().collection("Product")
		var products: [Product] = []
		
		do {
			let snapshot = try await db.whereField("storeId", isEqualTo: storeId).getDocuments()
			
			for snap in snapshot.documents {
				let data = snap.data()
				
				// Object
				let brand = data["brand"] as? String
				let category = data["category"] as? String
				let cbd = data["cbd"] as? Float
				let description = data["description"] as? String
				let discountPrice = data["discountPrice"] as? Double
				let images = data["images"] as? [String]
				let name = data["name"] as? String
				let nameLowerCase = data["nameLowerCase"] as? String
				let price = data["price"] as? Double
				let storeId = data["storeId"] as? String
				let thc = data["thc"] as? Float
				let weight = data["weight"] as? Float
				
				let product = Product(brand: brand, category: category, cbd: cbd, description: description, discountPrice: discountPrice, images: images, name: name, nameLowerCase: nameLowerCase, price: price, storeId: storeId, thc: thc, weight: weight, productId: snap.documentID)
				
				products.append(product)
			}
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return products
	}
	
	static func getItemsByName(name: String) async throws -> [Product]? {
		let db = Firestore.firestore().collection("Product")
		var products: [Product] = []
		
		do {
			let snapshot = try await db
				.whereField("nameLowerCase", isGreaterThanOrEqualTo: name)
				.whereField("nameLowerCase", isLessThanOrEqualTo: name + "\u{f7ff}")
				.getDocuments()
			
			for snap in snapshot.documents {
				let data = snap.data()
				
				// Object
				let brand = data["brand"] as? String
				let category = data["category"] as? String
				let cbd = data["cbd"] as? Float
				let description = data["description"] as? String
				let discountPrice = data["discountPrice"] as? Double
				let images = data["images"] as? [String]
				let name = data["name"] as? String
				let nameLowerCase = data["nameLowerCase"] as? String
				let price = data["price"] as? Double
				let storeId = data["storeId"] as? String
				let thc = data["thc"] as? Float
				let weight = data["weight"] as? Float
				
				let product = Product(brand: brand, category: category, cbd: cbd, description: description, discountPrice: discountPrice, images: images, name: name, nameLowerCase: nameLowerCase, price: price, storeId: storeId, thc: thc, weight: weight, productId: snap.documentID)
				
				products.append(product)
			}
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return products
	}
	
	static func deleteProduct(productId: String) async throws -> Bool {
		let db = Firestore.firestore().collection("Product")
		
		do {
			try await db.document(productId).delete()
			return true
			
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return false
		}
	}
	
	static func updateProduct(productId: String, product: Product) async throws -> Bool {
		let db = Firestore.firestore().collection("Product")
		
		do {
			let jsonObject = try JSONEncoder().encode(product)
			let productDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
			try await db.document(productId).updateData(productDict)
			
			return true
			
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return false
		}
	}
	
	static func getFeaturedStores() async throws -> [LocalStore]? {
		let db = Firestore.firestore().collection("Store")
		var stores: [LocalStore] = []
		
		do {
			let snapshot = try await db.whereField("isFeatured", isEqualTo: true).getDocuments()
			
			for snapp in snapshot.documents {
				let data = snapp.data()
				
				// Object
				let businessName = data["businessName"] as? String
				let businessNameLowerCase = data["businessNameLowercase"] as? String
				let businessType = data["businessType"] as? String
				let emailAdress = data["emailAddress"] as? String
				let geohash = data["geohash"] as? String
				let lat = data["lat"] as? Double
				let license = data["licence"] as? String
				let lng = data["lng"] as? Double
				let streetName = data["streetName"] as? String
				let fromTime = data["fromTime"] as? String
				let toTime = data["toTime"] as? String
				let city = data["city"] as? String
				let phone = data["phone"] as? String
				let photo = data["photo"] as? String
				let coverPhoto = data["coverPhoto"] as? String
				let website = data["website"] as? String
				let userId = data["userId"] as? String
                let deliveryFee = data["deliveryFee"] as? Double
                let stateTax = data["stateTax"] as? Double
                let salesTax = data["salesTax"] as? Double
				
				let store = LocalStore(businessName: businessName, businessNameLowerCase: businessNameLowerCase, businessType: businessType, emailAdress: emailAdress, geohash: geohash, lat: lat, license: license, lng: lng, streetName: streetName, city: city, phone: phone, photo: photo, coverPhoto: coverPhoto, userId: userId, website: website, storeId: snapp.documentID, fromTime: fromTime, toTime: toTime, deliveryFee: deliveryFee, salesTax: salesTax, stateTax: stateTax)
				
				stores.append(store)
			}
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return stores
	}
	
	static func getStoresByBusinessName(businessName: String) async throws -> [LocalStore]? {
		let db = Firestore.firestore().collection("Store")
		var stores: [LocalStore] = []
		
		do {
			let snapshot = try await db
				.whereField("businessNameLowercase", isGreaterThanOrEqualTo: businessName)
				.whereField("businessNameLowercase", isLessThanOrEqualTo: businessName + "\u{f7ff}")
				.getDocuments()
			
			for snapp in snapshot.documents {
				let data = snapp.data()
				
				// Object
				let businessName = data["businessName"] as? String
				let businessNameLowerCase = data["businessNameLowercase"] as? String
				let businessType = data["businessType"] as? String
				let emailAdress = data["emailAddress"] as? String
				let geohash = data["geohash"] as? String
				let lat = data["lat"] as? Double
				let license = data["licence"] as? String
				let lng = data["lng"] as? Double
				let streetName = data["streetName"] as? String
				let fromTime = data["fromTime"] as? String
				let toTime = data["toTime"] as? String
				let city = data["city"] as? String
				let phone = data["phone"] as? String
				let photo = data["photo"] as? String
				let coverPhoto = data["coverPhoto"] as? String
				let website = data["website"] as? String
				let userId = data["userId"] as? String
                let deliveryFee = data["deliveryFee"] as? Double
                let stateTax = data["stateTax"] as? Double
                let salesTax = data["salesTax"] as? Double
				
				let store = LocalStore(businessName: businessName, businessNameLowerCase: businessNameLowerCase, businessType: businessType, emailAdress: emailAdress, geohash: geohash, lat: lat, license: license, lng: lng, streetName: streetName, city: city, phone: phone, photo: photo, coverPhoto: coverPhoto, userId: userId, website: website, storeId: snapp.documentID, fromTime: fromTime, toTime: toTime, deliveryFee: deliveryFee, salesTax: salesTax, stateTax: stateTax)
				
				stores.append(store)
			}
		} catch let err {
			print("Error fetching data: \(err.localizedDescription)")
			return nil
		}
		return stores
	}
    
    static func getUserOrders() async throws -> [Order ]? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        let db = Firestore.firestore().collection("Order")
        var orders: [Order] = []
        
        do {
            let snapshot = try await db.whereField("userId", isEqualTo: uid).getDocuments()
            
            for snapp in snapshot.documents {
                let data = snapp.data()
                
                // Object
                let storeId = data["storeId"] as? String
                let storeName = data["storeName"] as? String
                let products = data["products"] as? [String]
                let orderTotal = data["orderTotal"] as? String
                let firstName = data["firstName"] as? String
                let lastName = data["lastName"] as? String
                let mobileNumber = data["mobileNumber"] as? String
                let deliveryMode = data["deliveryMode"] as? Int
                let deliveryStatus = data["deliveryStatus"] as? Int
                let deliverAddress = data["deliverAddress"] as? String
                let timestamp = data["timestamp"] as? Timestamp
                let qrCode = data["qrCode"] as? String
                
                let order = Order(storeId: storeId, storeName: storeName, products: products, userId: uid, orderTotal: orderTotal, firstName: firstName, lastName: lastName, mobileNumber: mobileNumber, deliveryMode: deliveryMode, deliveryStatus: deliveryStatus, deliverAddress: deliverAddress, timestamp: timestamp, qrCode: qrCode, orderId: snapp.documentID)
                
                orders.append(order)
            }
        } catch let err {
            print("Error fetching data: \(err.localizedDescription)")
            return nil
        }
        return orders
    }
    
    static func getOrdersByStoreId(storeId: String) async throws -> [Order]? {
        let query = Firestore.firestore().collection("Order").whereField("storeId", isEqualTo: storeId)
        var orders: [Order] = []
        
        do {
            let snapshot = try await query.getDocuments()

            for snapp in snapshot.documents {
                let data = snapp.data()
                
                // Object
                let userId = data["userId"] as? String
                let storeId = data["storeId"] as? String
                let storeName = data["storeName"] as? String
                let products = data["products"] as? [String]
                let orderTotal = data["orderTotal"] as? String
                let firstName = data["firstName"] as? String
                let lastName = data["lastName"] as? String
                let mobileNumber = data["mobileNumber"] as? String
                let deliveryMode = data["deliveryMode"] as? Int
                let deliveryStatus = data["deliveryStatus"] as? Int
                let deliverAddress = data["deliverAddress"] as? String
                let timestamp = data["timestamp"] as? Timestamp
                let qrCode = data["qrCode"] as? String
                
                let order = Order(storeId: storeId, storeName: storeName, products: products, userId: userId, orderTotal: orderTotal, firstName: firstName, lastName: lastName, mobileNumber: mobileNumber, deliveryMode: deliveryMode, deliveryStatus: deliveryStatus, deliverAddress: deliverAddress, timestamp: timestamp, qrCode: qrCode, orderId: snapp.documentID)
                
                orders.append(order)
            }
                
        } catch let err {
            print("Error fetching data: \(err.localizedDescription)")
            return nil
        }
        return orders
    }
    
    static func updateOrder(orderId: String, order: Order) async throws -> Bool {
        let db = Firestore.firestore().collection("Order")
        
        do {
            let jsonObject = try JSONEncoder().encode(order)
            let orderDict = try JSONSerialization.jsonObject(with: jsonObject) as! [String: Any]
            try await db.document(orderId).updateData(orderDict)
            
            return true
            
        } catch let err {
            print("Error fetching data: \(err.localizedDescription)")
            return false
        }
    }
}
