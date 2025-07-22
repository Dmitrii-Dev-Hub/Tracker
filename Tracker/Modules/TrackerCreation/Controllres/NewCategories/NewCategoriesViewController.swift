import UIKit

final class NewCategoriesViewController: UIViewController {
    
    private let viewModel: CategoriesViewModelProtocol
    
    private let textField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = R.Text.placeholderNewTracker
        textField.backgroundColor = R.ColorYP.backgroundDynamic
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private let doneButton = MainButton(title: R.Text.ButtonTitle.done.value)
    
    init(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayouts()
        setupAppearance()
        setupTextField()
        setupButtons()
    }
    
    @objc private func doneButtonTapped() {
        guard let text = textField.text else { return }
        let category = TrackerCategory(title: text, trackers: [])
        
        viewModel.addCategory(category: category)
        
        self.dismiss(animated: true)
    }
    
    @objc private func textChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text == "" {
            doneButton.isEnabled = false
            doneButton.backgroundColor = R.ColorYP.gray
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = R.ColorYP.blackDynamic
        }
    }
}

//MARK: - UITextFieldDelegate
extension NewCategoriesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - Setup UI
extension NewCategoriesViewController {
    private func setupViews() {
        view.addView(textField)
        view.addView(doneButton)
    }
    
    private func setupLayouts() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.whiteDynamic
        title = R.Text.newCategory
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    private func setupButtons() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.backgroundColor = R.ColorYP.gray
        doneButton.isEnabled = false
    }
}
