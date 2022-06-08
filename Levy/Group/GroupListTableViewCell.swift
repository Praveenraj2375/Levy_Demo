
import UIKit

class GroupListTableViewCell: UITableViewCell {
    
    private let containerView:UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        return view
    }()
    
    private let groupImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        //imageView.image = UIImage(systemName: "car")
        return imageView
    }()
    
    lazy var activityIndicator:UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    private let groupNameLabel:UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.setContentCompressionResistancePriority(UILayoutPriority(252), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(252), for: .horizontal)
        
        return label
    }()
    
    private let groupDescriptionLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
        
    }()
    
    private let shareAmountLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(253), for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .secondarySystemBackground
        
        configureContainerView()
        configureImageView()
        configureGroupNameLabel()
        configureGroupDescriptionLabel()
        configureShareAmountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        groupImageView.image = nil     
        activityIndicator.startAnimating()
    }
    
    private func configureContainerView(){
        contentView.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5)
        ])
    }

    func configureImageView(){
        containerView.addSubview(groupImageView)
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            groupImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            groupImageView.widthAnchor.constraint(equalToConstant: 52),
            groupImageView.heightAnchor.constraint(equalToConstant: 52)
        ])
        groupImageView.layer.cornerRadius = 26

        
        groupImageView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: groupImageView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: groupImageView.centerXAnchor)
        ])
        groupImageView.sendSubviewToBack(activityIndicator)
        
        
    }
    
    func configureGroupNameLabel(){
        containerView.addSubview(groupNameLabel)
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            groupNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 5),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor,constant: 5),
            
        ])
    }
    
    func configureGroupDescriptionLabel(){
        containerView.addSubview(groupDescriptionLabel)
        groupDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            groupDescriptionLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor,constant: 5),
            groupDescriptionLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor,constant: 5),
            groupDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5),
            groupDescriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -5)
        ])
    }
 
    func configureShareAmountLabel(){
        containerView.addSubview(shareAmountLabel)
        shareAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareAmountLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 5),
            shareAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: groupNameLabel.trailingAnchor, constant: 5),
            shareAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5)
        ])
    }
    
    private func setGroupImage(image: UIImage?) {
        self.groupImageView.image = image
    }
}

extension GroupListTableViewCell{
    func setGoupNameLabel(with value:String){
        groupNameLabel.text = value
    }
    func setGroupDescriptionLabel(with value:String){
        groupDescriptionLabel.text = value
    }
    func setShareAmountLabel(with value:Double){
        shareAmountLabel.setNumericValue(value: value)
    }
    func setGroupImage(with image:UIImage?){
            self.groupImageView.image = image
            self.activityIndicator.stopAnimating()
        
    }
}
