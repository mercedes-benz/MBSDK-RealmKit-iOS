//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import RealmSwift

open class ExtendedDbStore<BusinessModel: Entity, DbModel, Mapper: ExtendedDbModelMapping>: DbStore<BusinessModel, DbModel, Mapper> where Mapper.DbModel == DbModel, Mapper.BusinessModel == BusinessModel {

	open override func save(_ objects: [BusinessModel], update: Bool = true, completion: @escaping DbOperationObjectsResult) {
		
		guard objects.isEmpty == false else {
			completion(.success([]))
			return
		}
		
		self.dbOperating.realmWrite(.write, block: { realm in
			
			let dbModels = objects.map { (businessModel) -> DbModel in
				
				guard let dbModel = self.fetchDbModel(key: businessModel.id, realm: realm) else {
					return self.mapper.map(businessModel)
				}
				return self.mapper.map(businessModel, existing: dbModel)
			}
			
			self.deleteExistingList(of: dbModels, in: realm)
			realm.add(dbModels, update: update ? .modified : .error)
		}, completion: { result in
			switch result {
			case .success: completion(.success(objects))
			case .failure(let error): completion(.failure(error))
			}
		})
	}
}
