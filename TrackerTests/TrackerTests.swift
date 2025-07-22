
import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    // MARK: Light Theme
    
    // MARK: Main screen tests
    
    func testTrackersScreenLight() throws {
        let vc = TrackersViewController()
        
        assertSnapshots(of: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testTrackersNavBarLight() throws {
        let vc = TrackersViewController()
        let nc = TrackerNavigationController(rootViewController: vc)
        
        assertSnapshots(of: nc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testTabBarLight() throws {
        let tb = TabBarController()
        
        assertSnapshots(of: tb, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testTrackersCollectionNoCompletedCellLight() throws {
        let cell = TrackersCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 167, height: 132))
        let tracker = Tracker(id: UUID(), name: "Test", color: UIColor.white, emoji: "👽", timetable: [.monday], creationDate: Date())
        cell.configure(tracker: tracker, isCompleted: false, completedDays: 3, date: Date(), isPinned: false)
        
        assertSnapshots(of: cell, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testTrackersCollectionCompletedCellLight() throws {
        let cell = TrackersCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 167, height: 132))
        let tracker = Tracker(id: UUID(), name: "Test", color: UIColor.white, emoji: "👽", timetable: [.monday], creationDate: Date())
        cell.configure(tracker: tracker, isCompleted: true, completedDays: 3, date: Date(), isPinned: false)
        
        assertSnapshots(of: cell, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
}
