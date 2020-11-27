//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import UIKit
import RealmSwift

public extension UICollectionView {
	
	/// Update the collection view with applied changes from realm
	///
	/// - Parameters:
	///   - changes: RealmCollectionChange with generic realm object
	func applyChanges<T>(changes: RealmCollectionChange<T>) {
		
		switch changes {
		case .error(let error):
			print(error.localizedDescription)
			
		case .initial:
			self.reloadData()
			
		case .update(_, let deletions, let insertions, let modifications):
			let row = { IndexPath(row: $0, section: 0) }
			
			self.performBatchUpdates({
				
				self.insertItems(at: insertions.map(row))
				self.deleteItems(at: deletions.map(row))
				self.reloadItems(at: modifications.map(row))
			}, completion: nil)
		}
	}
	
	/// Update the collection view with applied changes from realm
	///
	/// - Parameters:
	///   - deletions: Array of IndexPaths with delete changes
	///   - insertions: Array of IndexPaths with insert changes
	///   - modifications: Array of IndexPaths with modify changes
	func applyChanges(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath]) {
		
		guard self.indexPathsForVisibleItems.isEmpty == false else {
			self.reloadData()
			return
		}
		
		let indexPaths = self.getRangedIndexPaths(for: self.indexPathsForVisibleItems, with: 2)
		let reload = self.intersect(paths: modifications, with: indexPaths)
		
		self.performBatchUpdates({
			
			self.insertItems(at: insertions)
			self.deleteItems(at: deletions)
			self.reloadItems(at: reload)
		}, completion: nil)
	}
	
	
	// MARK: - Helper
	
	fileprivate func getRangedIndexPaths(for indexPaths: [IndexPath], with range: Int) -> [IndexPath] {
		
		guard let maxRow = indexPaths.max()?.row,
			let minRow = indexPaths.min()?.row else {
				return indexPaths
		}
		
		let diff = range * indexPaths.count
		let row  = { IndexPath(row: $0, section: 0) }
		let maxSequence = Array(maxRow...(maxRow + diff)).map(row)
		let minSequence = Array(max(0, (minRow - diff))...minRow).map(row)
		
		return indexPaths + minSequence + maxSequence
	}
	
	fileprivate func intersect(paths origin: [IndexPath], with range: [IndexPath]) -> [IndexPath] {
		return Array(Set(origin).intersection(Set(range)))
	}
}
