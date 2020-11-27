//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import XCTest
import MBRealmKit

class RealmLayerDeleteTests: XCTestCase {
	
	// MARK: Lazy
	private lazy var listRealm: RealmLayer<DBListTestModel> = {
		return RealmLayer<DBListTestModel>(config: self.config)
	}()
	private lazy var simpleRealm: RealmLayer<DBSimpleTestModel> = {
		return RealmLayer<DBSimpleTestModel>(config: self.config)
	}()
	
	// MARK: Properties
	private let config = DatabaseTestConfig()
	
	
	// MARK: - Life cycle
	
	override func setUp() {
		self.deleteAll()
	}
	
	override func tearDown() {
		self.deleteAll()
	}
	
	func testDeleteListCascade() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeAsyncListObject(with: identifier) {
			
			if let object = self.listRealm.item(with: identifier) {
				
				self.simpleRealm.delete(list: object.list, method: .cascade, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.listRealm.all()?.count == 1 && self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteListNormal() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeAsyncListObject(with: identifier) {
			
			if let object = self.listRealm.item(with: identifier) {
				
				self.simpleRealm.delete(list: object.list, method: .normal, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.listRealm.all()?.count == 1 && self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteObjectArray() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		self.writeAsyncObjects(count: 10) {
			
			if let results = self.simpleRealm.all(), results.isEmpty == false {
				
				let modelArray = results.toArray(ofType: DBSimpleTestModel.self)
				self.simpleRealm.delete(objects: modelArray)
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteObjectCascade() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeAsyncListObject(with: identifier) {
			
			if let object = self.listRealm.item(with: identifier) {
				
				self.listRealm.delete(object: object, method: .cascade, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.listRealm.all()?.isEmpty == true && self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteObjectNormal() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeAsyncObject(with: identifier) {
			
			if let object = self.simpleRealm.item(with: identifier) {
				self.simpleRealm.delete(object: object, method: .normal, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteObjectsCascade() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		self.writeAsyncListObjects(count: 100) {
			
			if let results = self.listRealm.all(), results.isEmpty == false {
				self.listRealm.delete(results: results, method: .cascade, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.listRealm.all()?.isEmpty == true && self.simpleRealm.all()?.isEmpty == true)
	}
	
	func testDeleteObjectsNormal() {
		
		self.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		self.writeAsyncObjects(count: 100) {
			
			if let results = self.simpleRealm.all(), results.isEmpty == false {
				self.simpleRealm.delete(results: results, method: .normal, completion: {
					expectation.fulfill()
				})
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.simpleRealm.all()?.isEmpty == true)
	}
	
	
	// MARK: - Helper
	
	private func create(index: Int) -> DBListTestModel {
		
		let object = DBListTestModel()
		object.id = index
		return object
	}
	
	private func create(index: Int) -> DBSimpleTestModel {
		
		let object = DBSimpleTestModel()
		object.id = index
		object.value = UUID().uuidString
		return object
	}
	
	private func deleteAll() {
		
		self.listRealm.deleteAll()
		self.simpleRealm.deleteAll()
	}
	
	private func writeAsyncListObject(with identifier: Int, completion: @escaping () -> Void) {
		
		let object: DBListTestModel = self.create(index: identifier)
		let listObject: DBSimpleTestModel = self.create(index: identifier)
		object.list.append(listObject)
		
		self.listRealm.save(object: object, update: true, method: .async) {
			completion()
		}
	}
	
	private func writeAsyncListObjects(count: Int, completion: @escaping () -> Void) {
		
		var objects: [DBListTestModel] = []
		for index in 0..<count {
			
			let object: DBListTestModel = self.create(index: index)
			let listObject: DBSimpleTestModel = self.create(index: index)
			
			object.list.append(listObject)
			objects.append(object)
		}
		
		self.listRealm.save(objects: objects, update: true, method: .async) {
			completion()
		}
	}
	
	private func writeAsyncObject(with identifier: Int, completion: @escaping () -> Void) {
		
		let dbTestModel: DBSimpleTestModel = self.create(index: identifier)
		self.simpleRealm.save(object: dbTestModel, update: true, method: .async) {
			completion()
		}
	}
	
	private func writeAsyncObjects(count: Int, completion: @escaping () -> Void) {
		
		var objects: [DBSimpleTestModel] = []
		for index in 0..<count {
			objects.append(self.create(index: index))
		}
		
		self.simpleRealm.save(objects: objects, update: true, method: .async) {
			completion()
		}
	}
}
