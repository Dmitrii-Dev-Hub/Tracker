import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupTabBar()
    }
    
    // MARK: - Private Methods
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        tabBar.backgroundColor = R.ColorYP.whiteDynamic
        tabBar.isTranslucent = false
        tabBar.tintColor = R.ColorYP.blue
        tabBar.addTopBorder(color: R.ColorYP.separatorDynamic, thickness: 0.5)
    }
    
    private func setupTabBar() {
        let trackersVC = TrackersViewController()
        let trackersNavCon = TrackerNavigationController(rootViewController: trackersVC)
        trackersNavCon.tabBarItem = UITabBarItem(
            title: R.Text.MainScreen.trackers.value,
            image: R.ImagesYP.TabBar.tracker,
            selectedImage: nil
        )
        
        let statistic = StatisticViewController()
        let statisticNav = UINavigationController(rootViewController: statistic)
        statisticNav.tabBarItem = UITabBarItem(
            title: R.Text.MainScreen.statistic.value,
            image: R.ImagesYP.TabBar.statistic,
            selectedImage: nil
        )
        
        viewControllers = [trackersNavCon, statisticNav]
    }
}


