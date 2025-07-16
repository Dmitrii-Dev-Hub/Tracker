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
        view.backgroundColor = Resources.ColorYP.whiteDynamic
        tabBar.isTranslucent = false
        tabBar.tintColor = Resources.ColorYP.blue
        tabBar.addTopBorder(color: Resources.ColorYP.gray, thickness: 0.5)
    }
    
    private func setupTabBar() {
        let trackersVC = TrackersViewController()
        let trackersNavCon = TrackerNavigationController(rootViewController: trackersVC)
        trackersNavCon.tabBarItem = UITabBarItem(
            title: Resources.Text.tracker,
            image: Resources.ImagesYP.TabBar.tracker,
            selectedImage: nil
        )
        
        let statistic = UIViewController()
        let statisticNav = UINavigationController(rootViewController: statistic)
        statisticNav.tabBarItem = UITabBarItem(
            title: Resources.Text.statistic,
            image: Resources.ImagesYP.TabBar.statistic,
            selectedImage: nil
        )
        
        viewControllers = [trackersNavCon, statisticNav]
    }
}


