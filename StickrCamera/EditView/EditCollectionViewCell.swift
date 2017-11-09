//
//  FilterCollectionViewCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-01.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class EditCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.groupTableViewBackground.cgColor
        layer.borderWidth = 2
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








