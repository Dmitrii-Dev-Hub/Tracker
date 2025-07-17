import Foundation

final class CategoriesViewModel: NewCategoryStoreManagerDelegate, CategoriesViewModelProtocol {
    
    
    private let manager: CategoryStoreManager
    private(set) var selectedCategory: TrackerCategory? = nil {
        didSet {
            selectedCategoryBinding?(selectedCategory)
        }
    }
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    var categoriesBinding: Binding<[TrackerCategory]>?
    var selectedCategoryBinding: Binding<TrackerCategory?>?
    
    // MARK: Init
    
    init(categoryStore: TrackerCategoryStore, selectedCategory: TrackerCategory? = nil) {
        
        let manager = CategoryStoreManager(categoryStore: categoryStore)
        
        self.manager = manager
        self.manager.delegate = self
        self.categories = fetchCategories()
        self.selectedCategory = selectedCategory
    }
    
    convenience init(selectedCategory: TrackerCategory? = nil) {
        self.init(categoryStore: TrackerCategoryStore(), selectedCategory: selectedCategory)
    }
    
    // MARK: Methods
    private func fetchCategories() -> [TrackerCategory] {
        manager.fetchAll()
    }
    
    func addCategory(category: TrackerCategory) {
        manager.create(category: category)
    }
    
    func didSelect(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func didDeselect() {
        selectedCategory = nil
    }
    
    func insert(_ category: TrackerCategory, at indexPath: IndexPath) {
        categories.insert(category, at: indexPath.row)
    }
}
