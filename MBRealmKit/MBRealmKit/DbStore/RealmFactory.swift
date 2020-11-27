//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import RealmSwift

protocol RealmBuilder {
    init(config: RealmConfigProtocol)
    
    func build() -> Realm?
}

class RealmFactory: RealmBuilder {
    
    private let config: RealmConfigProtocol
    
    required init(config: RealmConfigProtocol) {
        self.config = config
    }
    
    func build() -> Realm? {
        
        let fileURL = self.config.realmFilename.isEmpty ?
            Realm.Configuration.defaultConfiguration.fileURL :
			Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent(self.config.realmFilename)
        
        let configuration = Realm.Configuration(fileURL: fileURL,
                                                inMemoryIdentifier: self.config.inMemoryIdentifier,
                                                encryptionKey: self.config.encryptionKey,
                                                readOnly: self.config.readOnly,
                                                schemaVersion: self.config.schemaVersion,
                                                migrationBlock: self.config.migrationBlock,
                                                deleteRealmIfMigrationNeeded: self.config.deleteRealmIfMigrationNeeded,
                                                shouldCompactOnLaunch: self.compactClosure(config: self.config),
                                                objectTypes: self.config.objects)

        do {
            return try Realm(configuration: configuration)
        } catch {
            LOG.E("Error init realm: \(error). Config: \(configuration)")
            return nil
        }
    }
    
    private func compactClosure(config: RealmConfigProtocol) -> ((Int, Int) -> Bool)? {
    
        guard let filesizeToCompact = config.filesizeToCompact else {
            return nil
        }
        
        return { (totalBytes, usedBytes) -> Bool in
            
            let fileSize = filesizeToCompact * 1024 * 1024
            return (totalBytes > fileSize) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        }
    }
}
