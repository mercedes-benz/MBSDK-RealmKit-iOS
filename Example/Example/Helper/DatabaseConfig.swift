//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift
import MBRealmKit

struct DatabaseConfig: RealmConfigProtocol {
	
	var deleteRealmIfMigrationNeeded: Bool {
		return true
	}
	var encryptionKey: Data? {
		return nil
	}
	var filename: String {
		return "RealmExample"
	}
	var filesizeToCompact: Int? {
		return 150
	}
	var inMemoryIdentifier: String? {
		return nil
	}
	var migrationBlock: MigrationBlock? {
		return nil
	}
	var objects: [ObjectBase.Type]? {
		return [
			DBDataModel.self
		]
	}
	var readOnly: Bool {
		return false
	}
	var schemaVersion: UInt64 {
		return 0
	}
}
