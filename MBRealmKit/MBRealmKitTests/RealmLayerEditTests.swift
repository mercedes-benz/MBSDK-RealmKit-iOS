//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import XCTest
import MBRealmKit

class RealmLayerEditTests: XCTestCase {
	
	// MARK: Lazy
	private lazy var realm: RealmLayer<DBSimpleTestModel> = {
		return RealmLayer<DBSimpleTestModel>(config: self.config)
	}()
	
	// MARK: Properties
	private let config = DatabaseTestConfig()
	
	
	// MARK: - Life cycle
	
	override func setUp() {
		self.realm.deleteAll()
	}
	
	override func tearDown() {
		self.realm.deleteAll()
	}
	
	func testEditObjectAsync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		let testValue = "hello world"
		self.writeAsyncObject(with: identifier) {
			
			if let object = self.realm.item(with: identifier) {
				
				self.realm.edit(item: object, method: .async, editBlock: { (_, item, editCompletion) in
					
					if item.isInvalidated == false {
						item.value = testValue
					}
					
					editCompletion()
				}, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		let object = self.realm.item(with: identifier)
		XCTAssertTrue(object?.value == testValue)
	}
	
	func testEditObjectSync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		let testValue = "hello world"
		self.writeAsyncObject(with: identifier) {
			
			if let object = self.realm.item(with: identifier) {
				
				self.realm.edit(item: object, method: .sync, editBlock: { (_, item, editCompletion) in
					
					if item.isInvalidated == false {
						item.value = testValue
					}
					
					editCompletion()
				}, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		let object = self.realm.item(with: identifier)
		XCTAssertTrue(object?.value == testValue)
	}
	
	func testEditResults() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let filteredCount = 10
		let totalCount = 100
		let testValue = "hello world"
		self.writeAsyncObjects(count: totalCount) {
			
			if let results = self.realm.all(), results.isEmpty == false {
				
				self.realm.edit(results: results, editBlock: { (_, results, editCompletion) in
					
					results.filter("id < %@", filteredCount).forEach {
						
						if $0.isInvalidated == false {
							$0.value = testValue
						}
					}
					
					editCompletion()
				}, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		
		let all = self.realm.all()
		let filtered = self.realm.all()?.filter("value = %@", testValue)
		
		XCTAssertTrue(all?.count == totalCount && filtered?.count == filteredCount)
	}
	
	
	// MARK: - Helper
	
	private func create(index: Int) -> DBSimpleTestModel {
		
		let object = DBSimpleTestModel()
		object.id = index
		object.value = UUID().uuidString
		return object
	}
	
	private func writeAsyncObject(with identifier: Int, completion: @escaping () -> Void) {
		
		let dbTestModel = self.create(index: identifier)
		self.realm.save(object: dbTestModel, update: true, method: .async) {
			completion()
		}
	}
	
	private func writeAsyncObjects(count: Int, completion: @escaping () -> Void) {
		
		var objects: [DBSimpleTestModel] = []
		for index in 0..<count {
			objects.append(self.create(index: index))
		}
		
		self.realm.save(objects: objects, update: true, method: .async) {
			completion()
		}
	}
}
