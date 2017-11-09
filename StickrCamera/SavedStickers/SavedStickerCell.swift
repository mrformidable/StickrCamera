//
//  SavedStickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-06.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class SavedStickerCell: UICollectionViewCell {
    
    let stickerImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "sticker")
        return imageView
    }()
    
    let stickerTitle:UILabel = {
        let label = UILabel()
        label.text = "Sticker Title Here"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(stickerImageView)
        addSubview(stickerTitle)
        let height = self.frame.size.height * 3/4
        print(height)
        
        stickerImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 2, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: height, widthConstant: 0)

        stickerTitle.anchorConstraints(topAnchor: stickerImageView.bottomAnchor, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
