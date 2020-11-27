//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift

public extension RealmLayer {
	
	// MARK: Typealias
	
	/// Completion for write transaction
	typealias SaveCompletion = () -> Void
	
	
	// MARK: - Public
	
	/// Add or update a object in a collection into the Realm.
	///
	/// - Parameters:
	///   - object: Generic object
	///   - update: Add or update the object
	///   - method: Method for write process (async or sync)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Closure with SaveCompletion
	func save(object: T, update: Bool, method: RealmConstants.RealmWriteMethod, withoutNotifying: [NotificationToken]? = nil, completion: SaveCompletion? = nil) {
		self.save(objects: [object], update: update, method: method, withoutNotifying: withoutNotifying, completion: completion)
	}
	
	/// Adds or updates an array of objects in a collection into the Realm.
	///
	/// - Parameters:
	///   - objects: Array of generic object
	///   - update: Add or update the object
	///   - method: Method for write process (async or sync)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - completion: Closure with SaveCompletion
	func save(objects: [T], update: Bool, method: RealmConstants.RealmWriteMethod, withoutNotifying: [NotificationToken]? = nil, completion: SaveCompletion? = nil) {
		
		guard let object = objects.first else {
			completion?()
			return
		}
		
		let hasPrimaryKey = object.objectSchema.primaryKeyProperty != nil
		let withUpdate    = update ? hasPrimaryKey : update
		
		switch method {
		case .async:	self.updateAsync(objects: objects, update: withUpdate, withoutNotifying: withoutNotifying, completion: completion)
		case .sync:		self.updateSync(objects: objects, update: withUpdate, withoutNotifying: withoutNotifying, completion: completion)
		}
	}
	
	
	// MARK: - Helper
	
	private func updateAsync(objects: [T], update: Bool, withoutNotifying: [NotificationToken]? = nil, completion: SaveCompletion?) {
		
		DispatchQueue(label: RealmConstants.WriteThread.async).async {
			
			autoreleasepool {
				
				RealmLayer.beginWrite(config: self.config) { (realm) in
					
					realm.add(objects, update: update ? .modified : .error)
					RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
				}
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	private func updateSync(objects: [T], update: Bool, withoutNotifying: [NotificationToken]? = nil, completion: SaveCompletion?) {
		
		RealmLayer.beginWrite(config: self.config) { (realm) in
			
			realm.add(objects, update: update ? .modified : .error)
			RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
			completion?()
		}
	}
}
