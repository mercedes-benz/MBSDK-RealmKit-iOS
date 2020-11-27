//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

public extension RealmLayer {
	
	// MARK: Typealias
	
	/// Completion for item changes
	///
	/// Returns a array of PropertyChange
	typealias ObserveItemChange = (_ properties: [PropertyChange]) -> Void
	
	/// Completion for item deletion
	///
	/// Returns a empty closure
	typealias ObserveItemDeleted = () -> Void
	
	/// Completion for initial item
	///
	/// Returns a the item
	typealias ObserveItemInitial = (T) -> Void
	
	/// Completion for observation error
	///
	/// Returns a error (ObserveError)
	typealias ObserveError = (RealmConstants.ObserveError) -> Void
	
	/// Completion for initial results
	///
	/// Returns a generic results
	typealias ObserveResultsInitial = (Results<T>) -> Void
	
	/// Completion for results changes
	///
	/// Returns a generic results, a array of deleted indices, a array of inserted indices and a array of modified indices
	typealias ObserveResultsUpdate = (Results<T>, _ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
	
	
	// MARK: - Public
	
	/// Fetch all objects in a collection into the Realm.
	///
	/// - Returns: A generic results
	func all() -> Results<T>? {
		return self.config.realm?.objects(T.self)
	}
	
	/// Fetch a object with his generic primary key
	///
	/// - Parameters:
	///   - primaryKey: Generic primary key
	/// - Returns: A generic object
	func item<K>(with primaryKey: K) -> T? {
		return self.config.realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
	}
	
	/// Start the observation of a object.
	///
	/// - Parameters:
	///   - item: Generic object
	///   - error: Closure that returns any kind of error during the observation
	///   - initial: Closure that returns the initial object
	///   - change: Closure that returns any changes of this object
	///   - deleted: Closure that returns when the object was deleted
	/// - Returns: Optional NotificationToken
	func observe(item: T?, error: @escaping ObserveError, initial: @escaping ObserveItemInitial, change: @escaping ObserveItemChange, deleted: @escaping ObserveItemDeleted) -> NotificationToken? {
		
		guard let item = item else {
			error(RealmConstants.ObserveError.itemNotFound)
			return nil
		}
		
		let token = item.observe { (status) in
			
			switch status {
			case .change(_, let properties):
				change(properties)
				
			case .deleted:
				deleted()
				
			case .error(let err):
				error(RealmConstants.ObserveError.realmError(message: err.localizedDescription))
			}
		}
		
		initial(item)
		return token
	}
	
	/// Start the observation of a results.
	///
	/// - Parameters:
	///   - results: Generic results
	///   - error: Closure that returns any kind of error during the observation
	///   - initial: Closure that returns the initial results
	///   - update: Closure that returns updates of the results
	/// - Returns: Optional NotificationToken
	func observe(results: Results<T>?, error: @escaping ObserveError, initial: @escaping ObserveResultsInitial, update: @escaping ObserveResultsUpdate) -> NotificationToken? {
		
		return results?.observe { (status) in
			
			switch status {
			case .error(let err):
				error(RealmConstants.ObserveError.realmError(message: err.localizedDescription))

			case .initial(let results):
				initial(results)

			case .update(_, let deletions, let insertions, let modifications):
				
				guard let newResults = self.all() else {
					return
				}
				update(newResults, deletions, insertions, modifications)
			}
		}
	}
}
