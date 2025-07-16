
import Foundation

protocol NewCategoryStoreManagerDelegate: AnyObject {
    func removeStubAndShowCategories(indexPath: IndexPath)
    func startUpdate()
}
