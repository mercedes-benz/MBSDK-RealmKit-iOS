//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import UIKit

/// Protocol to use realm with your view controller
public protocol RealmableViewController {
	
	/// Current token name
	var tokenName: String { get }
	
	/// Request the initial realm data
	func getDataFromRealm()
}


// MARK: - Extension

public extension RealmableViewController where Self: UIViewController {
	
	var tokenName: String {
		return String(describing: Self.self)
	}
}
