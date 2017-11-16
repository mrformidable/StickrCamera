//
//  StickerHeaderCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-04.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol StickerHeaderCellDelegate: class {
    func didTapSegment(_ segment:Int)
}

class StickerHeaderCell: UICollectionViewCell {
    
    weak var delegate:StickerHeaderCellDelegate?
    
    lazy var stickerSegmentControl:UISegmentedControl = {
       let segementControl = UISegmentedControl()
        segementControl.tintColor = .black
        segementControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: UIControlEvents.valueChanged)
      return segementControl
    }()
    
    @objc
    private func didChangeSegment(_ sender:UISegmentedControl) {
        delegate?.didTapSegment(sender.selectedSegmentIndex)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stickerSegmentControl)
        stickerSegmentControl.anchorConstraints(topAnchor: topAnchor, topConstant: 5, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 29, widthConstant: 0)
        stickerSegmentControl.insertSegment(withTitle: "Travel", at: 0, animated: true)
        stickerSegmentControl.insertSegment(withTitle: "Memes", at: 1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
