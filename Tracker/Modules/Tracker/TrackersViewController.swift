import UIKit


final class TrackersViewController: UIViewController {
    
    static var categories: [TrackerCategory] = Resources.Mocks.trackers
    private var trackerStoreManager: TrackerStoreManager?
    private var searchText: String? = nil
    static var currentDate = Date()
    
    private var collectionHelper: HelperTrackersCollectionView?
    
    private let stubView = NoContentView(text: Resources.Text.textNoContent, image: Resources.ImagesYP.dizzy)
    
    private let trackersCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(TrackersCollectionViewCell.self,
                            forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collection.register(SectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: SectionHeaderView.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = Resources.ColorYP.whiteDynamic
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        let currentWeekday = getCurrentWeekday()
//        filterTrackers(by: currentWeekday)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackersCollection.reloadData()
    }
    
    private func fetchCategories() -> [TrackerCategory] {
        trackerStoreManager?.fetchAllCategories() ?? []
    }
    
    private func getCurrentWeekday() -> Day {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: TrackersViewController.currentDate)
        let currentWeekday = Day.getDayFromNumber(number: weekday)
        
        return currentWeekday
    }
    
    private func reloadCollection() {
        trackersCollection.reloadData()
    }
    
    private func reloadCollectionAndSetup() {
        reloadCollection()
        setupSubviews()
    }
    
    private func trackersIsEmpty() -> Bool {
        trackerStoreManager?.trackersIsEmpty() ?? true
    }
    
    private func getFilteredTrackers(by day: Day) -> [TrackerCategory] {
        var filteredCategories = [TrackerCategory]()
        for category in TrackersViewController.categories {
            let trackers: [Tracker] = category.trackers.filter {
                if let timetable = $0.timetable {
                    return timetable.contains(day)
                } else {
                    guard let creationDate = $0.creationDate else {
                        assertionFailure("creation date is nil")
                        return false
                    }
                    return Calendar.current.isDate(creationDate, inSameDayAs: TrackersViewController.currentDate)
                }
            }

            let newCategory = TrackerCategory(title: category.title, trackers: trackers)
            filteredCategories.append(newCategory)
        }
        
        return filteredCategories
    }
    
//    private func filterTrackers(by day: Day) {
//        var filtered = getFilteredTrackers(by: day)
//
//        if let searchText = navigationItem.searchController?.searchBar.text, !searchText.isEmpty {
//            filtered = filtered.map { category in
//                let filteredTrackers = category.trackers.filter { item in
//                    guard let name = item.name else { return false }
//                    return name.lowercased().contains(searchText.lowercased())
//                }
//                return TrackerCategory(title: category.title, trackers: filteredTrackers)
//            }
//        }
//        reloadCollection()
//        setupSubviews()
//    }
//
//    private func trackersIsEmpty() -> Bool {
//        if TrackersViewController.categories.isEmpty {
//            return true
//        }
//
//        var trackersIsEmpty = true
//        for category in collectionHelper.categories {
//            if !category.trackers.isEmpty {
//                trackersIsEmpty = false
//            }
//        }
//
//        return trackersIsEmpty
//    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        trackerStoreManager?.create(tracker: tracker, category: category)
    }
}

// MARK: TrackerStoreManagerDelegate

extension TrackersViewController: TrackerStoreManagerDelegate {
    func addTracker(at indexPath: IndexPath) {
        if stubView.isHidden == false {
            stubView.removeFromSuperview()
            addTrackersCollection()
        }
        
        trackersCollection.reloadData()
    }
}

//MARK: - NewTrackerViewControllerDelegate
//extension TrackersViewController: NewTrackerViewControllerDelegate {
//    func addTracker() {
//        if !stubView.isHidden {
//            stubView.removeFromSuperview()
//            addTrackersCollection()
//        }
//        let weekday = getCurrentWeekday()
//        filterTrackers(by: weekday)
//        trackersCollection.reloadData()
//    }
//}


// MARK: UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.searchText = searchText
        } else {
            self.searchText = nil
        }
        
        trackerStoreManager?.setupFetchedResultsController(
            with: getCurrentWeekday(),
            and: searchText,
            date: TrackersViewController.currentDate
        )
        reloadCollectionAndSetup()
    }
}

//MARK: - TrackerNavigationControllerDelegate
extension TrackersViewController: TrackersNavigationControllerDelegate {
    func dateWasChanged(date: Date) {
        TrackersViewController.currentDate = date
        collectionHelper?.changeCurrentDate(date: date)
        trackerStoreManager?.setupFetchedResultsController(
            with: getCurrentWeekday(),
            and: searchText,
            date: TrackersViewController.currentDate
        )
        
        reloadCollectionAndSetup()
    }
    
    func addButtonTapped() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav, animated: true)
    }
}

//MARK: - UI

extension TrackersViewController {
    private func configure() {
        view.backgroundColor = Resources.ColorYP.whiteDynamic
        
        trackerStoreManager = TrackerStoreManager(
            trackerStore: TrackerStore(),
            categoryStore: TrackerCategoryStore()
        )
        trackerStoreManager?.delegate = self
        
        trackerStoreManager?.setupFetchedResultsController(
            with: getCurrentWeekday(),
            and: searchText,
            date: TrackersViewController.currentDate
        )
        
        guard let trackerStoreManager = trackerStoreManager else {
            return
        }
        
        collectionHelper = HelperTrackersCollectionView(
            trackerStoreManager: trackerStoreManager,
            with: GeometricParams(cellCount: 2, topInset: 12,
                                  leftInset: 0, bottomInset: 32,
                                  rightInset: 0, cellSpacing: 9)
        )
        
        trackersCollection.dataSource = collectionHelper
        trackersCollection.delegate = collectionHelper
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        if trackersIsEmpty() {
            if trackersCollection.isDescendant(of: view) {
                trackersCollection.removeFromSuperview()
            }
            addStubView()
        } else {
            addTrackersCollection()
        }
    }
    
    private func addTrackersCollection() {
        view.addView(trackersCollection)
        
        NSLayoutConstraint.activate([
            trackersCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollection.topAnchor.constraint(equalTo: view.topAnchor),
            trackersCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func addStubView() {
        view.addView(stubView)
        
        NSLayoutConstraint.activate([
            stubView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}

