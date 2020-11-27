//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift

public extension RealmLayer {
	
	// MARK: Typealias
	
	/// Completion for update transaction
	typealias EditCompletion = () -> Void
	
	/// Completion for update item transaction
	///
	/// Returns a thread safe realm, the item itself and a closure for the transaction (EditCompletion)
	typealias EditItemCompletion = (_ realm: Realm, _ item: T, _ commitWrite: @escaping EditCompletion) -> Void
	
	/// Completion for write transaction
	///
	/// Returns a thread safe realm, the generic results and a closure for the transaction (EditCompletion)
	typealias EditResultsCompletion = (_ realm: Realm, _ results: Results<T>, _ commitWrite: @escaping EditCompletion) -> Void
	
	
	// MARK: - Public
	
	/// Update a object in a collection into the Realm.
	///
	/// - Parameters:
	///   - item: Generic object
	///   - method: Method for write process (async or sync)
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - editBlock: Closure with EditItemCompletion. Please call this block after your changes.
	///   - completion: Optional closure with EditCompletion
	func edit(item: T, method: RealmConstants.RealmWriteMethod, withoutNotifying: [NotificationToken]? = nil, editBlock: @escaping EditItemCompletion, completion: EditCompletion?) {
		
		switch method {
		case .async:	self.updateAsync(item: item, withoutNotifying: withoutNotifying, editBlock: editBlock, completion: completion)
		case .sync:		self.updateSync(item: item, withoutNotifying: withoutNotifying, editBlock: editBlock, completion: completion)
		}
	}
	
	/// Update a generic results in a collection into the Realm.
	///
	/// - Parameters:
	///   - results: Generic results
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	///   - editBlock: Closure with EditResultsCompletion. Please call this block after your changes.
	///   - completion: Optional closure with EditCompletion
	func edit(results: Results<T>, withoutNotifying: [NotificationToken]? = nil, editBlock: @escaping EditResultsCompletion, completion: EditCompletion?) {
		
		let safeRef = ThreadSafeReference(to: results)
		DispatchQueue(label: RealmConstants.EditThread.async).async {
			
			autoreleasepool {
				
				guard let threadResults = self.config.realm?.resolve(safeRef) else {
                    LOG.E("Failed to resolve ThreadSafeReference")
					return
				}
				
				RealmLayer.beginWrite(config: self.config, completion: { (realm) in
					editBlock(realm, threadResults) {
						RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
					}
				})
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	
	// MARK: - Helper
	
	private func updateAsync(item: T, withoutNotifying: [NotificationToken]?, editBlock: @escaping EditItemCompletion, completion: EditCompletion?) {
		
		let safeRef = ThreadSafeReference(to: item)
		DispatchQueue(label: RealmConstants.EditThread.async).async {
			
			autoreleasepool {
				
				guard let threadItem = self.config.realm?.resolve(safeRef) else {
                    LOG.E("Failed to resolve ThreadSafeReference")
					return
				}
				
				RealmLayer.beginWrite(config: self.config) { (realm) in
					editBlock(realm, threadItem) {
						RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
					}
				}
			}
			
			self.finishedAsyncTask(completion: completion)
		}
	}
	
	private func updateSync(item: T, withoutNotifying: [NotificationToken]?, editBlock: @escaping EditItemCompletion, completion: EditCompletion?) {
		
		RealmLayer.beginWrite(config: self.config) { (realm) in
			editBlock(realm, item) {
				
				RealmLayer.commitWrite(realm: realm, withoutNotifying: withoutNotifying)
				completion?()
			}
		}
	}
}
