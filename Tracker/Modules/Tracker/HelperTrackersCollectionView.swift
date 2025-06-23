import UIKit

protocol TrackersCellDelegate: NSObject {
    func completeTracker(id: UUID)
    func incompleteTracker(id: UUID)
}

final class HelperTrackersCollectionView: NSObject  {
    var categories: [TrackerCategory]
    var visibleCategories: [TrackerCategory]?
    var completedTrackers: [TrackerRecord] = []
    var currentDate = Date()
    
    private let params: GeometricParams
    
    init(categories: [TrackerCategory], with params: GeometricParams) {
        self.categories = categories
        self.params = params
    }
    
    // MARK: Methods
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let completedTracker = TrackerRecord(id: id, date: currentDate)
        return completedTrackers.contains(completedTracker)
    }
}

// MARK: TrackersCellDelegate

extension HelperTrackersCollectionView: TrackersCellDelegate {
    func completeTracker(id: UUID) {
        let completedTracker = TrackerRecord(id: id, date: currentDate)
        completedTrackers.append(completedTracker)
    }
    
    func incompleteTracker(id: UUID) {
        completedTrackers.removeAll { trackerRecord in
            let isSameDate = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
            return trackerRecord.id == id && isSameDate
        }
    }
}

extension HelperTrackersCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath)
        guard let cell = cell as? TrackersCollectionViewCell else {
            print("Cell is nil")
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        
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
        
        if categories[indexPath.section].trackers.isEmpty {
            return view
        } else {
            let categoryName = categories[indexPath.section].title
            view.changeTitle(title: categoryName)
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width,
               height: categories[section].trackers.isEmpty ? 0 : 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if categories[section].trackers.isEmpty {
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
