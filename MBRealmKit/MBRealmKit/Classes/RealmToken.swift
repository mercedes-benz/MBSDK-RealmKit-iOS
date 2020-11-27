//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

/// Class to handle the realm-based notification token
public class RealmToken {
	
	private static let shared = RealmToken()
	
	// MARK: Properties
	private var tokens: [String: NotificationToken] = [:]
	
	
	// MARK: - Public
	
	/// Invalidate and reset your token
	///
	/// - Parameters:
	///   - key: Token name
	///   - isDeinit: Deinitialize the token. Is true by default.
	public static func invalide(for key: String, isDeinit: Bool = true) {
		
		self.shared.tokens[key]?.invalidate()
		if isDeinit {
			self.shared.tokens[key] = nil
		}
	}
	
	/// Add a token to storage
	///
	/// - Parameters:
	///   - token: Valid NotificationToken
	///   - key: Token name
	public static func set(token: NotificationToken?, for key: String) {
		
		self.invalide(for: key, isDeinit: false)
		self.shared.tokens[key] = token
	}
	
	/// Request a token for token name
	///
	/// - Parameters:
	///   - key: Token name
	/// - Returns: Optional token as NotificationToken
	public static func token(for key: String) -> NotificationToken? {
		return self.shared.tokens[key]
	}
}
