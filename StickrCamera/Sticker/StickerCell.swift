//
//  StickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {    
    
    var sticker:Sticker? {
        didSet {
            guard let _sticker = sticker else {
                return
            }
            stickerTitle.text = _sticker.title
            stickerImageView.image = _sticker.image
        }
    }
    
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
    
    private lazy var lockButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "lock_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapLockedButton), for: .touchUpInside)
        return button
    }()
    
    
    @objc
    private func didTapLockedButton() {
        print("tapped locked")
    }
   
    let unlockedPremiumState = UserDefaults.standard.bool(forKey: "unlockPremiumPurchaseMade")
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(stickerImageView)
        addSubview(stickerTitle)
        stickerImageView.addSubview(lockButton)
        let height = self.frame.size.height * 3/4
        
        stickerImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 2, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: height, widthConstant: 0)
        
        stickerTitle.anchorConstraints(topAnchor: stickerImageView.bottomAnchor, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)

        lockButton.anchorConstraints(topAnchor: stickerImageView.topAnchor, topConstant: 5, leftAnchor: nil, leftConstant: 0, rightAnchor: stickerImageView.rightAnchor, rightConstant: -5, bottomAnchor: nil, bottomConstant: 0, heightConstant: 26, widthConstant: 26)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        if unlockedPremiumState {
            lockButton.isHidden = true
        } else {
            lockButton.isHidden = false
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




