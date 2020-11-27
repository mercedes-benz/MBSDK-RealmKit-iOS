//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Realm-based constants
public struct RealmConstants {
	
	// MARK: Typealias
	
	/// Completion for error
	public typealias ErrorCompletion = () -> Void

	// MARK: Enum
	
	/// Error of observation results or items
	public enum ObserveError {
		case itemNotFound
		case realmError(message: String)
	}
	
	/// Method enum to write transaction
	public enum RealmWriteMethod {
		case async
		case sync
	}
	
	// MARK: Struct
	
	struct DeleteThread {
		
		static let async = "realm.delete.async"
		static let sync  = "realm.delete.sync"
	}
	
	struct EditThread {
		
		static let async = "realm.edit.async"
		static let sync  = "realm.edit.sync"
	}
	
	struct WriteThread {
		
		static let async = "realm.write.async"
		static let sync  = "realm.write.sync"
	}
}
