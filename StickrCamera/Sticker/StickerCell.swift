//
//  StickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import CoreData

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
    
    private lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var lockButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "lock_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapLockedButton), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func didTapLikeButton() {
        saveStickerToCoreData()
    }
    
    @objc
    private func didTapLockedButton() {
        print("tapped locked")
    }
    
    private func saveStickerToCoreData() {
        guard let managedObjContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
    
        guard let sticker = sticker else {return}
        let stickerImage = UIImageJPEGRepresentation(sticker.image, 1.0)!
        let savedSticker = SavedSticker(context: managedObjContext)
        savedSticker.stickerTitle = sticker.title
        savedSticker.stickerImage = stickerImage
        savedSticker.isPremium = sticker.isPremium
        savedSticker.isFavourite = sticker.isFavourite

        do {
            try managedObjContext.save()
            print("saved, show alert here also")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(stickerImageView)
        addSubview(stickerTitle)
        addSubview(likeButton)
        
        stickerImageView.addSubview(lockButton)
        let height = self.frame.size.height * 3/4
        
        stickerImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 2, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: height, widthConstant: 0)
        
        stickerTitle.anchorConstraints(topAnchor: stickerImageView.bottomAnchor, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: likeButton.leftAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        likeButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: nil, bottomConstant: 0, heightConstant: 40, widthConstant: 40)
        likeButton.centerYAnchor.constraint(equalTo: stickerTitle.centerYAnchor, constant: 0).isActive = true
        
        lockButton.anchorConstraints(topAnchor: stickerImageView.topAnchor, topConstant: 5, leftAnchor: nil, leftConstant: 0, rightAnchor: stickerImageView.rightAnchor, rightConstant: -5, bottomAnchor: nil, bottomConstant: 0, heightConstant: 26, widthConstant: 26)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




