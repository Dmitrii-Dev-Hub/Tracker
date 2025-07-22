import UIKit

final class TrackersViewController: UIViewController {
    // MARK: Properties
    
    static var currentDate = Date()
    
    private var trackerStoreManager: TrackerStoreManager?
    private var searchText: String? = nil
    private var lastNumberOfSections = 0
    private var filter: Filters = .all
    
    private let analyticsService = AnalyticsService()
    
    // MARK: Views
    
    private var collectionHelper: HelperTrackersCollectionView?
    
    private let emptyView = UIView()
    
    private let trackersCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier
        )
        collection.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = R.ColorYP.backgroundDynamic
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.clipsToBounds = false
        
        return collection
    }()
    
    private let filtersButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.ColorYP.blue
        button.tintColor = R.ColorYP.white
        button.setTitleColor(R.ColorYP.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let stubView = NoContentView(
        text: R.Text.textNoContent,
        image: R.ImagesYP.dizzy
    )
    private let filtersStubView = NoContentView(
        text: "Ничего не найдено",
        image: R.ImagesYP.image
    )
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rawValue = UserDefaults.standard.value(forKey: R.Keys.selectedFilter) as? Int
        filter = Filters(rawValue: rawValue ?? 0) ?? .all
        
        setupCollection()
        
        configure()
        reloadCollectionAndSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: Methods
    
    private func setupCollection() {
        trackerStoreManager = TrackerStoreManager(
            trackerStore: TrackerStore(),
            categoryStore: CategoryStore()
        )
        trackerStoreManager?.delegate = self
        
        trackerStoreManager?.setFilter(
            filter: filter,
            day: getCurrentWeekday(),
            text: searchText,
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
        collectionHelper?.delegate = self
        lastNumberOfSections = trackerStoreManager.numberOfSections
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
    
    private func reloadCollectionAndSetup() {
        guard let trackerStoreManager else { return }
        trackersCollection.reloadData()
        setupSubviews()
        lastNumberOfSections = trackerStoreManager.numberOfSections
    }
    
    private func trackersIsEmpty() -> Bool {
        trackerStoreManager?.trackersIsEmpty() ?? true
    }
    
    private func setFilteredStateForButton() {
        filtersButton.backgroundColor = .clear
        filtersButton.tintColor = R.ColorYP.blue
        filtersButton.setTitleColor(R.ColorYP.blue, for: .normal)
        filtersButton.layer.borderWidth = 2
        filtersButton.layer.borderColor = R.ColorYP.blue.cgColor
    }
    
    private func setNoFilteredStateForButton() {
        filtersButton.backgroundColor = R.ColorYP.blue
        filtersButton.tintColor = R.ColorYP.white
        filtersButton.setTitleColor(R.ColorYP.white, for: .normal)
        filtersButton.layer.borderWidth = 0
    }
    
    @objc func buttonFiltersTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        let filtersNC = UINavigationController(rootViewController: filtersVC)
        present(filtersNC, animated: true)
    }
}

// MARK: HelperTrackersCollectionViewDelegate

extension TrackersViewController: HelperTrackersCollectionViewDelegate {
    func showEditController(for tracker: Tracker, with category: TrackerCategory) {
//
        let editViewController = NewHabitOrEventViewController(trackerStore: TrackerStore(), categoryStore: CategoryStore(), tracker: tracker, category: category, isEdit: true)
        let editNavController = UINavigationController(rootViewController: editViewController)
        present(editNavController, animated: true)
    }
    
    func hideFiltersButton() {
        if filtersButton.transform == .identity {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.filtersButton.transform = CGAffineTransform(translationX: 0, y: 70)
                self?.filtersButton.alpha = 0.2
            }
        }
    }
    
    func showFiltersButton() {
        if filtersButton.transform != .identity {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.filtersButton.transform = .identity
                self?.filtersButton.alpha = 1
            }
        }
    }
}

// MARK: Extension

extension TrackersViewController/*: Protocol*/ {
    func setFilter(filter: Filters) {
        self.filter = filter
        
        if filter != .all {
            setFilteredStateForButton()
        } else {
            setNoFilteredStateForButton()
        }
        
        if filter == .today {
            guard let nc = navigationController as? TrackerNavigationController else { return }
            nc.setDate(date: Date())
            TrackersViewController.currentDate = Date()
            collectionHelper?.changeCurrentDate(date: Date())
        }
        
        trackerStoreManager?.setFilter(
            filter: filter,
            day: getCurrentWeekday(),
            text: searchText,
            date: TrackersViewController.currentDate
        )
        
        reloadCollectionAndSetup()
    }
}

// MARK: NewTrackerViewControllerDelegate

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        trackerStoreManager?.create(tracker: tracker, category: category)
    }
}

// MARK: TrackerStoreManagerDelegate

extension TrackersViewController: TrackerStoreManagerDelegate {
    func addTracker(at indexPath: IndexPath) {
        removeStub()
        reloadCollectionAndSetup()
    }
    
    func updateTracker(at indexPath: IndexPath) {
        trackersCollection.reloadData()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let trackerStoreManager else { return }
        if trackersIsEmpty() {
            trackersCollection.performBatchUpdates({
                trackersCollection.deleteSections(IndexSet(integer: indexPath.section))
            }, completion: { [weak self] _ in
                guard let self else { return }
                if trackerStoreManager.trackersIsEmpty(in: getCurrentWeekday(), or: TrackersViewController.currentDate) {
                    self.addStubAndRemoveCollection(stubAddingMethod: self.addStubView)
                } else {
                    self.addStubAndRemoveCollection(stubAddingMethod: self.addFiltersStubView)
                }
            })
        } else {
            trackersCollection.performBatchUpdates({
                
                if trackerStoreManager.numberOfSections != lastNumberOfSections {
                    trackersCollection.deleteSections(IndexSet(integer: indexPath.section))
                } else {
                    trackersCollection.deleteItems(at: [indexPath])
                }
            }, completion: nil)
        }
    }
    
    func forceReload() {
        trackersCollection.reloadData()
    }
}

// MARK: TrackersNavigationControllerDelegate

extension TrackersViewController: TrackersNavigationControllerDelegate {
    func dateWasChanged(date: Date) {
        if filter == .today {
            filter = .all
            UserDefaults.standard.setValue(0, forKey: R.Keys.selectedFilter)
            setNoFilteredStateForButton()
        }
        TrackersViewController.currentDate = date
        collectionHelper?.changeCurrentDate(date: date)
        trackerStoreManager?.setFilter(
            filter: filter,
            day: getCurrentWeekday(),
            text: searchText,
            date: TrackersViewController.currentDate
        )
        
        reloadCollectionAndSetup()
    }
    
    func addButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav, animated: true)
    }
}

// MARK: UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.searchText = searchText
        } else {
            self.searchText = nil
        }
        
        trackerStoreManager?.setFilter(
            filter: filter,
            day: getCurrentWeekday(),
            text: searchText,
            date: TrackersViewController.currentDate
        )
        reloadCollectionAndSetup()
    }
}

// MARK: UI configuration

extension TrackersViewController {
    private func configure() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        
        if filter != .all {
            setFilteredStateForButton()
        } else {
            setNoFilteredStateForButton()
        }
        filtersButton.addTarget(self, action: #selector(buttonFiltersTapped), for: .touchUpInside)
        
        trackersCollection.backgroundColor = R.ColorYP.whiteDynamic
        trackersCollection.dataSource = collectionHelper
        trackersCollection.delegate = collectionHelper
        
        addEmptyView()
        setupSubviews()
        setFiltersButton()
    }
    
    private func setupSubviews() {
        guard let trackerStoreManager else { return }
        showFiltersButton()
        if trackerStoreManager.trackersIsEmpty(in: getCurrentWeekday(), or: TrackersViewController.currentDate) {
            addStubAndRemoveCollection(stubAddingMethod: addStubView)
            hideFiltersButton()
            return
        }
        
        if trackersIsEmpty() {
            addStubAndRemoveCollection(stubAddingMethod: addFiltersStubView)
        } else  {
            removeStub()
            addTrackersCollection()
        }
    }
    
    private func removeStub() {
        if stubView.isDescendant(of: view) {
            stubView.removeFromSuperview()
        }
        
        if filtersStubView.isDescendant(of: view) {
            filtersStubView.removeFromSuperview()
        }
    }
    
    private func addStubAndRemoveCollection(stubAddingMethod: () -> Void) {
        if trackersCollection.isDescendant(of: view) {
            trackersCollection.removeFromSuperview()
        }
        removeStub()
        stubAddingMethod()
        view.bringSubviewToFront(filtersButton)
    }
    
    private func addEmptyView() {
        view.addView(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 0),
        ])
    }
    
    private func addTrackersCollection() {
        view.addView(trackersCollection)
        
        NSLayoutConstraint.activate([
            trackersCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollection.topAnchor.constraint(equalTo: view.topAnchor),
            trackersCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        view.bringSubviewToFront(filtersButton)
    }
    
    private func setFiltersButton() {
        view.addView(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func addStubView() {
        view.addView(stubView)
        hideFiltersButton()
        
        NSLayoutConstraint.activate([
            stubView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    private func addFiltersStubView() {
        view.addView(filtersStubView)
        
        NSLayoutConstraint.activate([
            filtersStubView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersStubView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersStubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            filtersStubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}
