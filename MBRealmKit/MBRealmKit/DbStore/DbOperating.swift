//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - DbOperatingQueue

public enum DbOperatingQueue: String {
	case delete = "realm.delete.async"
	case edit = "realm.edit.async"
	case write = "realm.write.async"
}

public protocol DbOperating {
	
	var realm: Realm? { get }
	
	func realmEdit(_ queue: DbOperatingQueue, block: @escaping (Realm, @escaping () -> Void) -> Void, completion: @escaping (Result<Void, DbError>) -> Void)
	func realmWrite(_ queue: DbOperatingQueue, block: @escaping (Realm) -> Void, completion: @escaping (Result<Void, DbError>) -> Void)
}


// MARK: - DbOperations

open class DbOperations<DbModel: Object> {
	
	private let realmBuilder: RealmBuilder
	private let callbackDispatchQueue: DispatchQueue
	
	public convenience init(
		config: RealmConfigProtocol,
		callbackDispatchQueue: DispatchQueue = DispatchQueue.main) {
		
		self.init(callbackDispatchQueue: callbackDispatchQueue,
				  builder: RealmFactory(config: config))
	}
	
	init(
		callbackDispatchQueue: DispatchQueue,
		builder: RealmBuilder) {
		
		self.callbackDispatchQueue = callbackDispatchQueue
		self.realmBuilder = builder
	}
	
	
	// MARK: - Helper
	
	private func dispatchAsync(_ queue: DbOperatingQueue, block: @escaping (() -> Void)) {
		DispatchQueue(label: queue.rawValue).async {
			autoreleasepool {
				block()
			}
		}
	}
	
	private func dispatchCallbackQ(_ block: @escaping () -> Void) {
		self.callbackDispatchQueue.asyncAfter(deadline: .now() + .milliseconds(1), execute: block)
	}
}


// MARK: - DbOperating

extension DbOperations: DbOperating {
	
	public var realm: Realm? {
		return self.realmBuilder.build()
	}
	
	public func realmEdit(_ queue: DbOperatingQueue, block: @escaping (Realm, @escaping () -> Void) -> Void, completion: @escaping (Result<Void, DbError>) -> Void) {
		
		// Doesn't use [weak self] inside the block, because this will call the autoreleasepool immediately if the DbStore hasn't a strong reference
		self.dispatchAsync(queue) {
			do {
				guard let realm = self.realm else {
					self.dispatchCallbackQ {
						completion(.failure(.realmConfigInvalid))
					}
					return
				}
				
				try realm.write {
					block(realm) {
						self.dispatchCallbackQ {
							completion(.success(()))
						}
					}
				}
			} catch {
				LOG.E("Error executing realm write: \(error)")
				self.dispatchCallbackQ {
					completion(.failure(DbError.realmError))
				}
			}
		}
	}
	
	public func realmWrite(_ queue: DbOperatingQueue, block: @escaping (Realm) -> Void, completion: @escaping (Result<Void, DbError>) -> Void) {
		
		// Doesn't use [weak self] inside the block, because this will call the autoreleasepool immediately if the DbStore hasn't a strong reference
		self.dispatchAsync(queue) {
			do {
				guard let realm = self.realm else {
					self.dispatchCallbackQ {
						completion(.failure(.realmConfigInvalid))
					}
					return
				}
				
				try realm.write {
					block(realm)
				}

				self.dispatchCallbackQ {
					completion(.success(()))
				}
			} catch {
				LOG.E("Error executing realm write: \(error)")
				self.dispatchCallbackQ {
					completion(.failure(DbError.realmError))
				}
			}
		}
	}
}
