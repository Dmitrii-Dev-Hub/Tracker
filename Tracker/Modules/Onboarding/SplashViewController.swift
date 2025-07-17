import UIKit

final class SplashViewController: UIViewController {
    // MARK: Properties
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .logoYP)
        return view
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupAppearance()
        setCurrentVC()
    }
    
    // MARK: Methods
    
    private func setupView() {
        view.addView(imageView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 94),
            imageView.widthAnchor.constraint(equalToConstant: 91),
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.blue
    }
    
    private func setCurrentVC() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        
        guard let window = sceneDelegate.window else {
            return
        }
        
        guard
            let _ = UserDefaults.standard.object(forKey: "Onboarding") as? Bool
        else {
            let onboarding = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            window.rootViewController = onboarding
            return
        }
        
        let tabBar = TabBarController()
        window.rootViewController = tabBar
        
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: nil,
                          completion: nil)
    }
}

