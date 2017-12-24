//
//  AddStickerCell.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-10.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class AddStickerCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.borderColor = UIColor.groupTableViewBackground.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
}
