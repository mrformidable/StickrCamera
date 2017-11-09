//
//  StickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {    
    
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
    
    private lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func didTapLikeButton() {
        print("like tapped")
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(stickerImageView)
        addSubview(stickerTitle)
        addSubview(likeButton)
        let height = self.frame.size.height * 3/4
        print(height)
        
        stickerImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 2, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: height, widthConstant: 0)
        
        stickerTitle.anchorConstraints(topAnchor: stickerImageView.bottomAnchor, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: likeButton.leftAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        likeButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: nil, bottomConstant: 0, heightConstant: 30, widthConstant: 30)
        likeButton.centerYAnchor.constraint(equalTo: stickerTitle.centerYAnchor, constant: 0).isActive = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}




