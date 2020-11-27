//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Entity {
    var id: String { get }
}

open class DbStore<BusinessModel: Entity, DbModel, Mapper: DbModelMapping>
                where Mapper.DbModel == DbModel, Mapper.BusinessModel == BusinessModel {
    
    public typealias DbOperationObjectsResult = ((Result<[BusinessModel], DbError>) -> Void)
    public typealias DbOperationObjectResult = ((Result<BusinessModel, DbError>) -> Void)
    public typealias DbOberationObjectOptResult = ((Result<BusinessModel?, DbError>) -> Void)
    public typealias DbOperationResult = ((Result<Void, DbError>) -> Void)
    
    private let realmBuilder: RealmBuilder
	let mapper: Mapper
	let dbOperating: DbOperating
    
	
	// MARK: - Init
	
    public convenience init(config: RealmConfigProtocol,
                            mapper: Mapper,
                            callbackDispatchQueue: DispatchQueue = DispatchQueue.main) {
        
        self.init(mapper: mapper,
				  builder: RealmFactory(config: config),
				  dbOperating: DbOperations(config: config,
											callbackDispatchQueue: callbackDispatchQueue))
    }
    
    init(mapper: Mapper,
         builder: RealmBuilder,
         dbOperating: DbOperating) {
        
        self.mapper = mapper
        self.realmBuilder = builder
		self.dbOperating = dbOperating
    }
	
    // MARK: Save
    
    open func save(_ objects: [BusinessModel], update: Bool = true, completion: @escaping DbOperationObjectsResult) {
        
        guard objects.isEmpty == false else {
            completion(.success([]))
            return
        }
        
        let dbModels = objects.map { self.mapper.map($0) }
        
		self.dbOperating.realmWrite(.write, block: { realm in
			
			self.compare(objects: dbModels, in: realm)
			self.deleteExistingList(of: dbModels, in: realm)
            realm.add(dbModels, update: update ? .modified : .error)
        }, completion: { result in
            switch result {
            case .success: completion(.success(objects))
            case .failure(let error): completion(.failure(error))
            }
        })
    }

    open func save(_ object: BusinessModel, update: Bool = true, completion: @escaping DbOperationObjectResult) {
        
        self.save([object], update: update) { result in
            switch result {
            case .success: completion(.success(object))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    // MARK: Query
    open func fetchAll() -> [BusinessModel] {
		return self.fetchDbModels()?.compactMap { self.mapper.map($0) } ?? []
    }
    
    open func fetch(key: Any) -> BusinessModel? {
        
		guard let result = self.fetchDbModel(key: key, realm: self.dbOperating.realm) else {
            return nil
        }
        
        return self.mapper.map(result)
    }
    
    open func fetch(predicate: NSPredicate) -> [BusinessModel] {
		return self.fetchDbModels()?.filter(predicate).compactMap { self.mapper.map($0) } ?? []
    }
    
    // MARK: Delete
    open func deleteAll(completion: @escaping DbOperationResult) {

		self.dbOperating.realmWrite(.delete, block: { realm in
            realm.deleteAll()
        }, completion: completion)
    }
    
    open func delete(_ object: BusinessModel, completion: @escaping DbOperationResult) {
        self.delete([object], completion: completion)
    }
    
    open func delete(_ objects: [BusinessModel], completion: @escaping DbOperationResult) {
        
		guard objects.isEmpty == false else {
            completion(.success(()))
            return
        }
		
		self.dbOperating.realmWrite(.delete, block: { [weak self] (realm) in
            objects.forEach {
				if let obj = self?.fetchDbModel(key: $0.id, realm: realm) {
                    realm.deleteCascade(object: obj)
                }
            }
        }, completion: completion)
    }
	
    
    // MARK: - Private Helpers
    
	func compare(objects: [DbModel], in realm: Realm) {
		
		objects.forEach { (object) in
			object.objectSchema.properties.forEach { (property) in
				
				if property.type == .object,
				   let propertyObject = object[property.name] as? Object {
					
					if let primaryKey = object.objectSchema.primaryKeyProperty?.name,
						let primaryValue = object[primaryKey],
						let existingObject = self.fetchDbModel(key: primaryValue, realm: realm),
						let existingPropertyObject = existingObject[property.name] as? Object {
						
						if existingPropertyObject.isSameObject(as: propertyObject) {
							realm.deleteCascade(object: propertyObject)
						} else {
							realm.deleteCascade(object: existingPropertyObject)
						}
					}
				}
			}
		}
	}
	
	func deleteExistingList(of objects: [DbModel], in realm: Realm) {
		
		objects.forEach { (object) in
			
			if let primaryKey = object.objectSchema.primaryKeyProperty?.name,
				let primaryValue = object[primaryKey],
				let existingObject = self.fetchDbModel(key: primaryValue, realm: realm) {

				existingObject.objectSchema.properties.filter({ $0.isArray }).forEach { (property) in

					if let listBase = existingObject[property.name] as? ListBase, listBase.count > 0 {
						existingObject.dynamicList(property.name).forEach { realm.deleteCascade(object: $0) }
					}
				}
			}
		}
	}
	
	func fetchDbModel(key: Any, realm: Realm?) -> DbModel? {
        return realm?.object(ofType: DbModel.self, forPrimaryKey: key)
    }
	
	private func fetchDbModels() -> Results<DbModel>? {
		return self.dbOperating.realm?.objects(DbModel.self)
	}
}
