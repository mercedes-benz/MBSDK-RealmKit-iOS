//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift
import MBCommonKit

#if canImport(MBCommonKitLogger)
import MBCommonKitLogger
#endif

let LOG = MBLogger.shared

/// Abstracted, object type based layer to use all the functionalities of realm very easily
public class RealmLayer<T: Object> {
	
	// MARK: Typealias
	
	/// Closure for thread safed realms
	///
	/// - Returns: A thread safe realm
	public typealias RealmClosure = (_ realm: Realm) -> Void
	
	/// Closure to compare a device specific realm with a bundle specific realm
	///
	/// - Returns: A device specific realm and a bundle specific realm
	public typealias RealmCompareClosure = (_ deviceRealm: Realm, _ bundleRealm: Realm) -> Bool
	
	/// Completion for realm based write transactions
	///
	/// - Returns: A thread safe realm and a transaction closure
	public typealias RealmSaveSyncClosure = (_ realm: Realm, _ saved: @escaping () -> Void) -> Void

	// MARK: Properties
	
	/// Configuration
	public internal (set) var config: RealmConfigProtocol
	
	
	// MARK: - Init
	
	/// Initialize a object type based layer
	///
	/// - Parameters:
	///   - config: Configuration of the realm which is conform to the RealmConfigProtocol
	public init(config: RealmConfigProtocol) {
		
		self.config = config
		
		self.skipRealmFileFromICloudBackup()
	}
	
	
	// MARK: - Public
	
	/// Begin the write transaction
	///
	/// - Parameters:
	///   - config: Configuration of the realm
	///   - completion: Closure with RealmClosure
	public static func beginWrite(config: RealmConfigProtocol, completion: RealmClosure) {
		
		guard let realm = config.realm else {
            LOG.E("Failed to create realm")
			return
		}
		
		realm.beginWrite()
		completion(realm)
	}
	
	/// Commit and end the write transaction
	///
	/// - Parameters:
	///   - realm: A thread safe realm which is used for the write transaction
	///   - withoutNotifying: All NotificationTokens that should not receive transaction notification
	public static func commitWrite(realm: Realm, withoutNotifying: [NotificationToken]? = nil) {
		
		do {
			if let withoutNotifying = withoutNotifying,
				withoutNotifying.isEmpty == false {
				try realm.commitWrite(withoutNotifying: withoutNotifying)
			} else {
				try realm.commitWrite()
			}
		} catch {
			LOG.E("Failed to commit write to database: \(error.localizedDescription)")
		}
	}
	
	/// Handle and map the error during a observation
	///
	/// - Parameters:
	///   - observeError: Case of the error (ObserveError)
	///   - completion: Closure with ErrorCompletion
	public static func handle(observeError: RealmConstants.ObserveError, completion: RealmConstants.ErrorCompletion?) {
		
		switch observeError {
		case .itemNotFound:				completion?()
		case .realmError(let message):	LOG.E(message)
		}
	}
	
	/// Write transaction
	///
	/// - Parameters:
	///   - config: Configuration of the realm
	///   - completion: Closure with RealmClosure
	public static func write(config: RealmConfigProtocol, completion: RealmClosure) {
		
		guard let realm = config.realm else {
            LOG.E("Failed to create realm")
			return
		}
		
        do {
            try realm.write {
                completion(realm)
            }
        } catch {
            LOG.E("Failed to write to database: \(error.localizedDescription)")
        }
	}
	
	
	// MARK: - Internal
	
	func finishedAsyncTask(completion: (() -> Void)?) {
		
		let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(1)
		DispatchQueue.main.asyncAfter(deadline: deadline) {
			completion?()
		}
	}
	
	
	// MARK: - Helper
	
	private func skipRealmFileFromICloudBackup() {
		
		guard let realm = self.config.realm,
			var realmFileURL = realm.configuration.fileURL,
			var realmResourceValue = try? realmFileURL.resourceValues(forKeys: [.isExcludedFromBackupKey]),
			FileManager.default.fileExists(atPath: realmFileURL.path) == true,
			realmResourceValue.isExcludedFromBackup == false else {
				return
			}
		
		do {

			realmResourceValue.isExcludedFromBackup = true
			try realmFileURL.setResourceValues(realmResourceValue)
		} catch {
			LOG.E("Failed to exclude realm from icloud backup")
		}
	}
}
