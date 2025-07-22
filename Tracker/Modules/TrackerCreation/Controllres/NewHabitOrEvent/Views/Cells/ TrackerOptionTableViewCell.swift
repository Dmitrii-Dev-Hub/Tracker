import UIKit

final class TrackerOptionTableViewCell: UITableViewCell {
    
    static let identifier = "TrackerOptionTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        detailTextLabel?.textColor = R.ColorYP.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSchedule(days: [Day]) {
        textLabel?.text = "Расписание"
        if days.count == 7 {
            detailTextLabel?.text = "Каждый день"
            return
        }
        
        let values = days.map { Day.shortName(by: $0.rawValue) }
        detailTextLabel?.text = values.joined(separator: ", ")
    }
    
    func configureCategory(subtitle: String) {
        textLabel?.text = "Категория"
        detailTextLabel?.text = subtitle
    }
}
