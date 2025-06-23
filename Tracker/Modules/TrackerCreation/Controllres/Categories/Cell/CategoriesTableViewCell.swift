import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with title: TrackerCategory) {
        self.textLabel?.text = title.title
        self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textLabel?.textColor = Resources.ColorYP.blackDynamic
        self.backgroundColor = Resources.ColorYP.backgroundDynamic
    }
}

