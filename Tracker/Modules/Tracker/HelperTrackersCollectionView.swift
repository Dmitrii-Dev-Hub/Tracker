import UIKit

protocol TrackersCellDelegate: NSObject {
    func completeTracker(id: UUID)
    func incompleteTracker(id: UUID)
}

final class HelperTrackersCollectionView: NSObject  {
    
    private var currentDate = Date()
    
    private let trackerStoreManager: TrackerStoreManager
    private let trackerRecordStore = TrackerRecordStore()
    
    private let params: GeometricParams
    
    init(trackerStoreManager: TrackerStoreManager, with params: GeometricParams) {
        self.trackerStoreManager = trackerStoreManager
        self.params = params
    }
    
    // MARK: Methods
    
    func changeCurrentDate(date: Date) {
        currentDate = date
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
       trackerRecordStore.fetch(by: id, and: currentDate) != nil
    }
}

// MARK: TrackersCellDelegate

extension HelperTrackersCollectionView: TrackersCellDelegate {
    func completeTracker(id: UUID) {
        let completedTracker = TrackerRecord(id: id, date: currentDate)
        trackerRecordStore.add(trackerRecord: completedTracker)
    }
    
    func incompleteTracker(id: UUID) {
        trackerRecordStore.delete(id: id, date: currentDate)
    }
}

// MARK: UICollectionViewDataSource

extension HelperTrackersCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStoreManager.numberOfRowsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStoreManager.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.identifier,
            for: indexPath
        )
        
        guard let cell = cell as? TrackersCollectionViewCell else {
            print("Cell is nil")
            return UICollectionViewCell()
        }

        guard let tracker = trackerStoreManager.object(at: indexPath) else {
            print("tracker is nil in CollectionViewCell")
            return UICollectionViewCell()
        }
        
        let isCompleted = isTrackerCompletedToday(id: tracker.id)
        let completedDays = trackerRecordStore.fetchCount(by: tracker.id)
        
        cell.delegate = self
        cell.configure(tracker: tracker, isCompleted: isCompleted, completedDays: completedDays, date: currentDate)
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension HelperTrackersCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath)
        
        guard let view = view as? SectionHeaderView else {
            print("SectionHeaderView is nil")
            return UICollectionReusableView()
        }
        
        if trackerStoreManager.categoryIsEmpty(in: indexPath.section) {
            return view
        } else {
            let categoryName = trackerStoreManager.categoryTitle(in: indexPath.section)
            view.changeTitle(title: categoryName, leadingAnchor: 12)
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if trackerStoreManager.categoryIsEmpty(in: section) {
            return CGSize(width: collectionView.frame.width, height: 0)
        } else {
            return CGSize(width: collectionView.frame.width, height: 19)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if trackerStoreManager.categoryIsEmpty(in: section) {
            return UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
        } else {
            return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 132)
    }
}
