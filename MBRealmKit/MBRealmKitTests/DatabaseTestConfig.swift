//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift
import MBRealmKit

struct DatabaseTestConfig: RealmConfigProtocol {
	
	var deleteRealmIfMigrationNeeded: Bool {
		return true
	}
	var encryptionKey: Data? {
		return nil
	}
	var filename: String {
		return ""
	}
	var filesizeToCompact: Int? {
		return 150
	}
	var inMemoryIdentifier: String? {
		return "RealmTestExample"
	}
	var migrationBlock: MigrationBlock? {
		return nil
	}
	var objects: [ObjectBase.Type]? {
		return [
			DBListTestModel.self,
			DBSimpleTestModel.self
		]
	}
	var readOnly: Bool {
		return false
	}
	var schemaVersion: UInt64 {
		return 0
	}
}
