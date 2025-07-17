import UIKit

final class CategoriesViewController: UIViewController, UINavigationControllerDelegate {
    
    private var viewModel: CategoriesViewModelProtocol
    weak var delegate: CategoriesViewControllerDelegate?
    
    // MARK: Init
    
    init(selectedCategory:TrackerCategory? = nil, delegate: CategoriesViewControllerDelegate? = nil) {
        
        self.delegate = delegate
        viewModel = CategoriesViewModel(selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = R.ColorYP.gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let stubView = NoContentView(text: R.Text.textNoCategory,
                                         image: R.ImagesYP.dizzy)
    
    private let createButton = MainButton(title: R.Text.ButtonTitle.createCategory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.categoriesBinding = { [weak self] _ in
            guard let self = self else { return }
            if self.stubView.isHidden == false {
                self.stubView.removeFromSuperview()
                self.setupTableView()
            }
            
            self.tableView.reloadData()
        }
        
        setupSubviews()
        setupAppearance()
        setupNavController()
        setupTableView()
        setupButtons()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.delegate?.selectedCategory = viewModel.selectedCategory
    }
    
    
    @objc private func createButtonTapped() {
        let newCategoryViewController = NewCategoriesViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: newCategoryViewController)
        present(nav, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell",
                for: indexPath
            ) as? CategoriesTableViewCell
        else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        let categories = viewModel.categories
        let selectedCategory = viewModel.selectedCategory
        
        cell.configureCell(with: category.title)
        if selectedCategory != nil && cell.textLabel?.text == selectedCategory?.title {
            let imageView = UIImageView(image: R.ImagesYP.checkmark)
            cell.accessoryView = imageView
        }
        
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []

        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1
        let isSingle = categories.count == 1

        if isSingle {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryView == nil {
            let imageView = UIImageView(image: R.ImagesYP.checkmark)
            cell.accessoryView = imageView
            
            let category = viewModel.categories[indexPath.row]
            
            viewModel.didSelect(category)
            navigationController?.popViewController(animated: true)
        } else {
            cell.accessoryView = nil
            viewModel.didDeselect()
        }
    }
}

//MARK: - Setup UI
extension CategoriesViewController {
    private func setupSubviews() {
        setupDoneButton()
        let categories = viewModel.categories
        categories.isEmpty ? setupStubView() : setupTableViewLayouts()
    }
    
    private func setupStubView() {
        view.addView(stubView)
        
        NSLayoutConstraint.activate([
            stubView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stubView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    
    
    private func setupTableViewLayouts() {
        view.addView(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 25),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -16),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor,
                                              constant: -24),
        ])
    }
    
    private func setupDoneButton() {
        view.addView(createButton)
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupLayoutsCategoriesTableView() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 25),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -16),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor,
                                              constant: -24),
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = R.ColorYP.whiteDynamic
    }
    
    private func setupNavController() {
        title = R.Text.category
        navigationItem.hidesBackButton = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoriesTableViewCell.self,
                           forCellReuseIdentifier: "cell")
    }
    
    private func setupButtons() {
        createButton.addTarget(self, action: #selector(createButtonTapped),
                               for: .touchUpInside)
    }
}

