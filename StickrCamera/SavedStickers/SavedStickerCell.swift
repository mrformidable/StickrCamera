//
//  SavedStickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-06.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol SavedStickerDelegate: class {
    func didTapDeleteButton(for cell: SavedStickerCell)
}

class SavedStickerCell: UICollectionViewCell {
    
    var savedSticker:SavedSticker? {
        didSet {
            guard let savedSticker = savedSticker, let imageData = savedSticker.stickerImage else {  return  }
            stickerImageView.image = UIImage(data: imageData)
            stickerTitle.text = savedSticker.stickerTitle
        }
    }
    
    weak var delegate:SavedStickerDelegate?
    
    private let stickerImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "sticker")
        return imageView
    }()
    
    private let stickerTitle:UILabel = {
        let label = UILabel()
        label.text = "Sticker Title Here"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var deleteButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "delete_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc
    private func didTapDeleteButton() {
        print("did tap delete")
        delegate?.didTapDeleteButton(for: self)
    }
    
    @objc
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showDeleteButton), name: NSNotification.Name.init("showDeleteButton"), object: nil)
        
        backgroundColor = .white
        addSubview(stickerImageView)
        addSubview(stickerTitle)
        stickerImageView.addSubview(deleteButton)
        let height = self.frame.size.height * 3/4
        
        stickerImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 2, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: height, widthConstant: 0)
        
        stickerTitle.anchorConstraints(topAnchor: stickerImageView.bottomAnchor, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        deleteButton.anchorConstraints(topAnchor: stickerImageView.topAnchor, topConstant: 4, leftAnchor: nil, leftConstant: 0, rightAnchor: stickerImageView.rightAnchor, rightConstant: -4, bottomAnchor: nil, bottomConstant: 0, heightConstant: 26, widthConstant: 26)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
