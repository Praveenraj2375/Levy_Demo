//
//  ImagePickerCollectionViewCell.swift
//  demoImagePicker
//
//  Created by Praveenraj T on 15/04/22.
//

import UIKit

class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    static let Identifier = "ImagePickerCollectionViewCell"
    
    let imageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        return imageView
    }()
    lazy var activityIndicator:UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.center = contentView.center
        backgroundView = activityIndicator
 
        configureImageView()
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        backgroundView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    func configureImageView(){
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func isHaveImage()->Bool{
        if imageView.image == nil{
            return false
        }
        return true
    }

}
