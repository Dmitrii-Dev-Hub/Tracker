import Foundation

protocol CategoriesViewModelProtocol: NewCategoryStoreManagerDelegate {
    var selectedCategory: TrackerCategory? { get }
    var categories: [TrackerCategory] { get }
    
    var categoriesBinding: Binding<[TrackerCategory]>? { get set }
    var selectedCategoryBinding: Binding<TrackerCategory?>? { get set }
    
    func addCategory(category: TrackerCategory)
    func didSelect(_ category: TrackerCategory)
    func didDeselect()
    func insert(_ category: TrackerCategory, at indexPath: IndexPath)
}
