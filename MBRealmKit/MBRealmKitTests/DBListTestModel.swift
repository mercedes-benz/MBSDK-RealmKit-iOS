//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

@objcMembers class DBListTestModel: Object {
	
	dynamic var id: Int = 0
	dynamic var value: String = ""
	
	let list = List<DBSimpleTestModel>()
	
	
	// MARK: - Realm
	
	override public static func primaryKey() -> String? {
		return "id"
	}
}
