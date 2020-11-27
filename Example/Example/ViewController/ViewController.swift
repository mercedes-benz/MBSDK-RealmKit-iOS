//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import UIKit
import RealmSwift
import MBRealmKit

class ViewController: UIViewController {
	
	// MARK: Lazy
	private lazy var realm: RealmLayer<DBDataModel> = {
		return RealmLayer<DBDataModel>(config: self.config)
	}()
	
	// MARK: IBOutlet
	@IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

	// MARK: Properties
	private let config = DatabaseConfig()
	
	
	// MARK: - View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.realm.deleteAll()
	}
	
	
	// MARK: - Actions
	
	@IBAction func fetchButtonPressed(_ sender: UIButton) {
		_ = self.fetch()
	}
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		self.startMultipleSaving()
	}
	
	@IBAction func saveSingleButtonPressed(_ sender: UIButton) {
		self.startSingleSaving()
	}
	
	
	// MARK: - Helper
	
	private func add(completion: @escaping (DBDataModel?) -> Void) {

		let id = 1
		let object = self.create(index: id)
		self.realm.save(object: object, update: true, method: .async) { [weak self] in
			
			print("*** finished")
			let item = self?.realm.item(with: id)
			if let item = item {
				print("\(item.id) - \(item.value))")
			}
			completion(item)
		}
	}
	
	private func add(count: Int, completion: @escaping (Results<DBDataModel>?) -> Void) {
		
		var objects: [DBDataModel] = []
		for index in 0..<count {
			objects.append(self.create(index: index))
		}
		
		self.realm.save(objects: objects, update: true, method: .async) { [weak self] in
			
			print("*** finished")
			let results = self?.fetch()
			completion(results)
		}
	}
	
	private func create(index: Int) -> DBDataModel {
		
		let object = DBDataModel()
		object.id = index
		object.value = UUID().uuidString
		return object
	}
	
	private func fetch() -> Results<DBDataModel>? {
		
		guard let results = self.realm.all() else {
			print("no results available")
			return nil
		}
		
		print("count: \(results.count)")
		return results
	}
	
	private func startMultipleSaving() {
		
		self.activityIndicatorView.startAnimating()
		self.realm.deleteAll()
		self.add(count: 1000) { [weak self] (_) in
			
			self?.realm.deleteAll()
			self?.add(count: 10000, completion: { [weak self] (_) in
				
				self?.realm.deleteAll()
				self?.add(count: 20000, completion: { [weak self] (_) in
					
					self?.realm.deleteAll()
					self?.add(count: 50000, completion: { [weak self] (_) in
						
						self?.realm.deleteAll()
						self?.add(count: 2000, completion: { [weak self] (_) in
							
							self?.realm.deleteAll()
							self?.add(count: 1000, completion: { [weak self] (_) in
								self?.activityIndicatorView.stopAnimating()
							})
						})
					})
				})
			})
		}
	}
	
	private func startSingleSaving() {

		self.activityIndicatorView.startAnimating()
		self.realm.deleteAll()
		self.add { [weak self] (_) in
			
			self?.realm.deleteAll()
			self?.add { [weak self] (_) in
				
				self?.realm.deleteAll()
				self?.add { [weak self] (_) in
					
					self?.realm.deleteAll()
					self?.add { [weak self] (_) in
						
						self?.realm.deleteAll()
						self?.add { [weak self] (_) in
							
							self?.realm.deleteAll()
							self?.add { [weak self] (_) in
								self?.activityIndicatorView.stopAnimating()
							}
						}
					}
				}
			}
		}
	}
}
