import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .bPrimary
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 6),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(with date: Date?) {
        if let date = date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            
            
            formatter.dateFormat = "d"
            dateLabel.text = formatter.string(from: date)
            
            formatter.dateFormat = "LLL"
            dayLabel.text = formatter.string(from: date)
            
            dateLabel.textColor = .lTertiary
            dayLabel.textColor = .lTertiary
        } else {
            dateLabel.text = ""
            dayLabel.text = "Другое"
            dayLabel.textColor = .lTertiary
        }
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .cGray : .bPrimary
            contentView.layer.borderColor = isSelected ? UIColor.lSecondary.cgColor : UIColor.clear.cgColor
            dateLabel.textColor = isSelected ? .lSecondary : .lTertiary
            dayLabel.textColor = isSelected ? .lSecondary : .lTertiary
        }
    }
}
