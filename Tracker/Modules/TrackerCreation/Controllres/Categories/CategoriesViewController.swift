import UIKit

final class CategoriesViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate: CategoriesViewControllerDelegate?
    
    private var tableIsEmpty = true
    
    private var selectedCategory: TrackerCategory? = nil
    private var categoryStoreManager: CategoryStoreManager?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Resources.ColorYP.gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let stubView = NoContentView(text: Resources.Text.textNoCategory,
                                         image: Resources.ImagesYP.dizzy)
    
    private let createButton = MainButton(title: Resources.Text.ButtonTitle.createCategory)
    
    init(delegate: CategoriesViewControllerDelegate? = nil, selectedCategory: TrackerCategory? = nil) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryStoreManager = CategoryStoreManager(
            categoryStore: TrackerCategoryStore(),
            delegate: self
        )
        tableIsEmpty = (categoryStoreManager?.numberOfRowsInSection(0) ?? 0 == 0) ? true : false
        
        setupSubviews()
        setupAppearance()
        setupNavController()
        setupTableView()
        setupButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        delegate?.selectedCategory = selectedCategory
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func categoryDidSelect(category: TrackerCategory) {
        selectedCategory = category
        navigationController?.popViewController(animated: true)
    }
    
    private func categoryDidDeselect() {
        selectedCategory = nil
    }
    
    @objc private func createButtonTapped() {
        let newCategoriesVC = NewCategoriesViewController()
        let navVC = UINavigationController(rootViewController: newCategoriesVC)
        newCategoriesVC.delegate = self
        present(navVC, animated: true)
    }
}

//MARK: - NewCategoryViewControllerDelegate
extension CategoriesViewController: NewCategoryViewControllerDelegate{
    func add(category: TrackerCategory) {
        categoryStoreManager?.create(category: category)
    }
}

//MARK: - NewCategoryViewControllerDelegate
extension CategoriesViewController: NewCategoryStoreManagerDelegate {
    func removeStubAndShowCategories(indexPath: IndexPath) {
        if stubView.isHidden == false {
            stubView.removeFromSuperview()
            setupTableView()
        }

        if tableIsEmpty {
            tableView.endUpdates()
            tableIsEmpty = false
            return
        } else {
            tableView.performBatchUpdates {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        tableView.endUpdates()
    }
    
    func startUpdate() {
        tableView.beginUpdates()
    }
}

//MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryStoreManager?.numberOfRowsInSection(section) ?? 0
        print(categoryStoreManager?.numberOfRowsInSection(section))
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
        
        guard let category = categoryStoreManager?.object(at: indexPath) else {
            print("Category is nil in creation cell")
            return UITableViewCell()
        }
        
        cell.configureCell(with: category)
        print(category)
        if selectedCategory != nil && cell.textLabel?.text == selectedCategory?.title {
            let imageView = UIImageView(image: Resources.ImagesYP.checkmark)
            cell.accessoryView = imageView
        }
        
//        if(category.count == 1){
//            cell.layer.cornerRadius = 16
//        } else if (indexPath.row == 0 && category.count > indexPath.row) {
//            cell.layer.cornerRadius = 16
//            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        } else if (indexPath.row == category.count-1 && category.count != 0 ) {
//            cell.layer.cornerRadius = 16
//            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//            tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//        }  else {
//            cell.layer.cornerRadius = 0.0
//        }

        //MARK: DOTO - доделать нижние подчеркивание
        
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
        
        guard let category = categoryStoreManager?.object(at: indexPath) else {
            print("Category is nil in did select cell")
            return
        }
        
        if cell.accessoryView == nil {
            let imageView = UIImageView(image: Resources.ImagesYP.checkmark)
            cell.accessoryView = imageView
            categoryDidSelect(category: category)
        } else {
            cell.accessoryView = nil
            categoryDidDeselect()
        }
    }
}

//MARK: - Setup UI
extension CategoriesViewController {
    private func setupSubviews() {
        setupDoneButton()
        tableIsEmpty ? setupStubView() : setupTableViewLayouts()
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -24),
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
        view.backgroundColor = Resources.ColorYP.whiteDynamic
    }
    
    private func setupNavController() {
        title = Resources.Text.category
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
