//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import RealmSwift

// MARK: - DbModelMapping

public protocol DbModelMapping {
    
    associatedtype BusinessModel
    associatedtype DbModel: RealmSwift.Object
    
    func map(_ dbModel: DbModel) -> BusinessModel
    func map(_ businessModel: BusinessModel) -> DbModel
}


// MARK: - ExtendedDbModelMapping

public protocol ExtendedDbModelMapping: DbModelMapping {
	func map(_ businessModel: BusinessModel, existing dbModel: DbModel) -> DbModel
}
