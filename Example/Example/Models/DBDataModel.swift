//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

@objcMembers class DBDataModel: Object {
	
	dynamic var id: Int = 0
	dynamic var value: String = ""
	
	
	// MARK: - Realm
	
	override public static func primaryKey() -> String? {
		return "id"
	}
}
