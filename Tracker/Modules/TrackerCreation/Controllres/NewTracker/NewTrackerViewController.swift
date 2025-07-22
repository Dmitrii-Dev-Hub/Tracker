import UIKit

final class NewTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let habitButton = MainButton(title: R.Text.NavTitle.habit.value)
    private let eventButton = MainButton(title: R.Text.NavTitle.event.value)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayouts()
        setupAppearance()
        setupButtonActions()
    }
    
    private func setupViews() {
        view.addView(stackView)
        
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(eventButton)
    }
    
    private func setupLayouts() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -16),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        title = R.Text.NavTitle.newTracker.value
        
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: R.ColorYP.blackDynamic
        ]
    }
    
    private func setupButtonActions() {
        habitButton.addTarget(self, action: #selector(newHabitButtonTapped), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(newEventButtonTapped), for: .touchUpInside)
    }
    
    @objc private func newHabitButtonTapped() {
        let viewController = NewHabitOrEventViewController(type: .habit)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func newEventButtonTapped() {
        let viewController = NewHabitOrEventViewController(type: .event)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - NewTrackerViewControllerDelegate
extension NewTrackerViewController: NewHabitOrEventViewDelegate {
    func addTracker(tracker: Tracker, category: TrackerCategory) {
        delegate?.addTracker(tracker: tracker, category: category)
    }
}
