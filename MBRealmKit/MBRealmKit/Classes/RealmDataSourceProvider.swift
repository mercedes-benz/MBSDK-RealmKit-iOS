//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import RealmSwift

/// Data source provider to handle and map realm object to his business model
open class RealmDataSourceProvider<DatabaseModel: Object, BusinessModel> {
	
	// MARK: Typealias
	
	/// Type of business model
	public typealias BusinessModelType = BusinessModel
	
	/// Database object
	public typealias DatabaseModelType = DatabaseModel
	
	// MARK: Properties
	private (set) var collection: AnyBidirectionalCollection<DatabaseModel>?
	public internal (set) var results: Results<DatabaseModel>?

	
	// MARK: - Public
	
	/// Count of the collection
	public var count: Int {
		return self.results?.count ?? self.collection?.count ?? 0
	}
	
	/// A Boolean value indicating whether the collection is empty.
	public var isEmpty: Bool {
		return self.results?.isEmpty ?? self.collection?.isEmpty ?? true
	}
	
	/// Get the index based database model and map it to the corresponding business model
	///
	/// - Parameters:
	///   - index: Index of the item in the collection
	/// - Returns: Optional business model
	public func item(at index: Int) -> BusinessModel? {
		
		let databaseItem: DatabaseModel? = self.results?.item(at: index) ?? self.collection?.item(at: index)
		guard let item = databaseItem else {
			return nil
		}
		
		return self.map(model: item)
	}
	
	/// Map the a database model into a business model. Please make sure that you override this method in your own sub class.
	///
	/// - Parameters:
	///   - model: Database model
	/// - Returns: Optional business model
	open func map(model: DatabaseModel) -> BusinessModel? {
		return nil
	}
	
	
	// MARK: - Init
	
	/// Initialize the data source provider
	///
	/// - Parameters:
	///   - collection: A bidirectional collection of database model
	public init(collection: AnyBidirectionalCollection<DatabaseModel>) {
		self.collection = collection
	}
	
	/// Initialize the data source provider
	///
	/// - Parameters:
	///   - filterCollection: A lazy filter collection of a results
	public init(filterCollection: LazyFilterCollection<Results<DatabaseModel>>) {
		self.collection = AnyBidirectionalCollection(filterCollection)
	}
	
	/// Initialize the data source provider
	///
	/// - Parameters:
	///   - results: Results of object
	public init(results: Results<DatabaseModel>) {
		self.results = results
	}
}


// MARK: - AnyBidirectionalCollection

extension AnyBidirectionalCollection {
	
	fileprivate func item(at index: Int) -> AnyBidirectionalCollection.Element? {
		
		let lazyIndex: Index = {
			
			guard index > 0 else {
				return self.startIndex
			}
			
			var prev = self.startIndex
			for _ in 1...index {
				prev = self.index(after: prev)
			}
			return prev
		}()
		
		if self.startIndex <= lazyIndex && lazyIndex < self.endIndex {
			return self[lazyIndex]
		}
		
		return nil
	}
}
