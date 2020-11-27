//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift

public extension RealmLayer {

	// MARK: Typealias
	
	/// Completion for delete transaction
	typealias DeleteCompletion = () -> Void
	
	// MARK: Enum
	enum RealmDeleteMethod {
		case cascade
		case normal
	}
	
	
	// MARK: - Public
	
	/// Delete a object in a collection into the Realm.
	///
	/// - Parameters:
	///   - object: Generic object
	///   - method: Method for delete process (cascade or normal)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Optional closure with DeleteCompletion
	func delete(object: T, method: RealmDeleteMethod, withoutNotifying: [NotificationToken]? = nil, completion: DeleteCompletion?) {
		
		let safeRef = ThreadSafeReference(to: object)
		DispatchQueue(label: RealmConstants.DeleteThread.async).async {
			
			autoreleasepool {
				
				guard let threadObject = self.config.realm?.resolve(safeRef) else {
                    LOG.E("Failed to resolve ThreadSafeReference")
					return
				}
				
				RealmLayer.beginWrite(config: self.config) { (realm) in
					
					if threadObject.isInvalidated == false {
						
						switch method {
						case .cascade:	realm.deleteCascade(object: threadObject)
						case .normal:	realm.delete(threadObject)
						}
					}
					
					RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
				}
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	/// Delete a array of objects in a collection into the Realm.
	///
	/// - Parameters:
	///   - objects: Array of generic objects
	func delete(objects: [T]) {
		
		RealmLayer.write(config: self.config) { (realm) in
			realm.delete(objects)
		}
	}
	
	/// Delete a generic realm list.
	///
	/// - Parameters:
	///   - list: Generic realm list
	///   - method: Method for delete process (cascade or normal)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Optional closure with DeleteCompletion
	func delete(list: List<T>, method: RealmDeleteMethod, withoutNotifying: [NotificationToken]? = nil, completion: DeleteCompletion?) {
		
		let safeRef = ThreadSafeReference(to: list)
		DispatchQueue(label: RealmConstants.DeleteThread.async).async {
			
			autoreleasepool {
				
				guard let threadList = self.config.realm?.resolve(safeRef) else {
                    LOG.E("Failed to resolve ThreadSafeReference")
					return
				}
				
				RealmLayer.beginWrite(config: self.config) { (realm) in
					
					if threadList.isInvalidated == false {
						
						switch method {
						case .cascade:
							threadList.forEach {
								realm.deleteCascade(object: $0)
							}
							
						case .normal:
							realm.delete(threadList)
						}
					}
					
					RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
				}
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	/// Delete a generic realm results.
	///
	/// - Parameters:
	///   - results: Generic realm results
	///   - method: Method for delete process (cascade or normal)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Optional closure with DeleteCompletion
	func delete(results: Results<T>, method: RealmDeleteMethod, withoutNotifying: [NotificationToken]? = nil, completion: DeleteCompletion?) {
		
		let safeRef = ThreadSafeReference(to: results)
		DispatchQueue(label: RealmConstants.DeleteThread.async).async {
			
			autoreleasepool {
				
				guard let threadResults = self.config.realm?.resolve(safeRef) else {
                    LOG.E("Failed to resolve ThreadSafeReference")
					return
				}
				
				RealmLayer.beginWrite(config: self.config) { (realm) in
					
					if threadResults.isInvalidated == false {
						
						switch method {
						case .cascade:
							threadResults.forEach {
								realm.deleteCascade(object: $0)
							}
							
						case .normal:
							realm.delete(threadResults)
						}
					}
					
					RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
				}
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	/// Delete all objects within a realm configuration.
	func deleteAll() {
		
		RealmLayer.write(config: self.config) { (realm) in
			realm.deleteAll()
		}
	}
}
