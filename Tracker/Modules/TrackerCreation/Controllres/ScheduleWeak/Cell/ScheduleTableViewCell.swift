import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    static let identifier = "ScheduleTableViewCell"
    
    let switchView: UISwitch = {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = R.ColorYP.blue
        switchView.backgroundColor = R.ColorYP.backgroundDynamic
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = switchView
        backgroundColor = R.ColorYP.backgroundDynamic
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        switchView.setOn(false, animated: true)
    }
    
    func configure(title: String) {
        textLabel?.text = title
    }
}
