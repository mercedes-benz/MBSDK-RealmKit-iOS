//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import XCTest
import MBRealmKit

class RealmLayerWriteTests: XCTestCase {
	
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
	
	func testWriteEmptyObjectAsync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		self.realm.save(objects: [], update: true, method: .async) {
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.realm.all()?.isEmpty == true)
	}
	
	func testWriteEmptyObjectSync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		self.realm.save(objects: [], update: true, method: .sync) {
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(self.realm.all()?.isEmpty == true)
	}
	
	func testWriteObjectAndFetchAfterCompletionAsync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeAsyncObject(with: identifier) {
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		let object: DBSimpleTestModel? = self.realm.item(with: identifier)
		XCTAssertTrue(object != nil && object?.id == identifier)
	}
	
	func testWriteObjectAndFetchAfterCompletionSync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		self.writeSyncObject(with: identifier) {
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		let object: DBSimpleTestModel? = self.realm.item(with: identifier)
		XCTAssertTrue(object != nil && object?.id == identifier)
	}
	
	func testWriteObjectAndFetchInCompletionAsync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		var object: DBSimpleTestModel?
		self.writeAsyncObject(with: identifier) {
			
			object = self.realm.item(with: identifier)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(object != nil && object?.id == identifier)
	}
	
	func testWriteObjectAndFetchInCompletionSync() {
		
		self.realm.deleteAll()
		
		let expectation = self.expectation(description: #function)
		
		let identifier = Int.random(in: 1...100000)
		var object: DBSimpleTestModel?
		self.writeSyncObject(with: identifier) {
			
			object = self.realm.item(with: identifier)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
		XCTAssertTrue(object != nil && object?.id == identifier)
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
	
	private func writeSyncObject(with identifier: Int, completion: @escaping () -> Void) {
		
		let dbTestModel = self.create(index: identifier)
		self.realm.save(object: dbTestModel, update: true, method: .sync) {
			completion()
		}
	}
}
