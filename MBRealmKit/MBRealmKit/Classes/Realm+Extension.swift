//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

// MARK: - List

internal protocol RealmLayerList {
	var children: [Object] { get }
}

extension List: RealmLayerList {
	
	internal var children: [Object] {
		return self.compactMap { $0 as? Object }
	}
}

/// Protocol to configure realm
public extension List {
	
	/// Delete all the objects from a list
	///
	/// - Parameters:
	///   - method: Method for delete process (cascade or normal)
	///   - type: Type of object
	func delete<T: Object>(method: RealmLayer<T>.RealmDeleteMethod, type: T.Type) {
		
		guard let list = self as? List<T>,
			self.isInvalidated == false else {
				return
		}
		
		switch method {
		case .cascade:
			list.forEach {
				self.realm?.deleteCascade(object: $0)
			}
			
		case .normal:
			self.realm?.delete(list)
		}
	}
	
	/// Get the index based element of the list
	///
	/// - Parameters:
	///   - index: Index of the item in the collection
	/// - Returns: Optional element of the list
	func item(at index: Int) -> Element? {
		
		if 0..<self.count ~= index {
			return self[index]
		}
		
		return nil
	}
}


// MARK: - Object

public extension Object {
	
	/// Delete a object in a collection into the Realm.
	///
	/// - Parameters:
	///   - config: Configuration of the realm
	///   - method: Method for delete process (cascade or normal)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Optional closure with DeleteCompletion
	func delete(config: RealmConfigProtocol, method: RealmLayer<Object>.RealmDeleteMethod, withoutNotifying: [NotificationToken]? = nil, completion: RealmLayer<Object>.DeleteCompletion?) {
		
		let realmLayer = RealmLayer<Object>(config: config)
		realmLayer.delete(object: self, method: method, withoutNotifying: withoutNotifying, completion: completion)
	}
}


// MARK: - Realm

public extension Realm {
	
	/// Delete a cascading object in a collection into the Realm.
	///
	/// - Parameters:
	///   - object: Main object which should be deleted
	func deleteCascade(object: Object) {
		
		guard object.isInvalidated == false else {
			return
		}
		
		for property in object.objectSchema.properties {
			
			guard let propertyObject = object.value(forKey: property.name) else {
				continue
			}
			
			if let cascadeObject = propertyObject as? Object {
				self.deleteCascade(object: cascadeObject)
			}
			
			if let objectList = propertyObject as? RealmLayerList {
				
				objectList.children.forEach {
					self.deleteCascade(object: $0)
				}
			}
		}
		
		self.delete(object)
	}
}


// MARK: - Results

public extension Results {
	
	/// Get the index based element of the results
	///
	/// - Parameters:
	///   - index: Index of the item in the collection
	/// - Returns: Optional element of the results
	func item(at index: Int) -> Element? {
		
		if 0..<self.count ~= index {
			return self[index]
		}
		
		return nil
	}
	
	/// Map the results to a array of objects. Notice: Don't use this method for big results because the conversion from results to array blocks the main thread.
	///
	/// - Parameters:
	///   - ofType: Generic based object type
	/// - Returns: Array of objects
	func toArray<T>(ofType: T.Type) -> [T] {
		return self.compactMap { $0 as? T } as [T]
	}
}
