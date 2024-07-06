import UIKit

class RoundedTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .bSecondary
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel!)
        NSLayoutConstraint.activate([
            textLabel!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.top),
            textLabel!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding.left),
            textLabel!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding.right),
            textLabel!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.bottom)
        ])
    }
    
    
}
