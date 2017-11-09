//
//  StickerViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol StickerViewDelegate: class {
    func didSelectSticker(_ image:UIImage)
}

class StickerViewController: UICollectionViewController {
    
    private let stickerCellIdentifier = "StickerCell"
    
    private let stickerHeaderCellIdentier = "StickerHeaderCell"
    
    weak var delegate:StickerViewDelegate?
    
    var stickerArray = [Sticker]()
    var secondStickerArray = [Sticker]()
    
    var currentSegment = 0
    
    private var isInitialLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.groupTableViewBackground
        collectionView?.register(StickerCell.self, forCellWithReuseIdentifier: stickerCellIdentifier)
        collectionView?.register(StickerHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: stickerHeaderCellIdentier)
        collectionView?.contentInset = UIEdgeInsetsMake(5, 2, 0, 2)
        
        UINavigationBar.appearance().tintColor = .black
        let leftBarButtonItem =  UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "like_icon_filled"), style: .plain
            , target: self, action: #selector(savedBarButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "Stickers"
        
        let sticker1 = Sticker(image: #imageLiteral(resourceName: "sticker"), title: "Send Noods", isPremium: false, isFavourite: false)
        let sticker2 = Sticker(image: #imageLiteral(resourceName: "sticker2"), title: "1-800-STFU", isPremium: false, isFavourite: false)
        let sticker3 = Sticker(image: #imageLiteral(resourceName: "sticker3"), title: "Cherry Flav", isPremium: false, isFavourite: false)
        let sticker4 = Sticker(image: #imageLiteral(resourceName: "sticker4"), title: "Wierdo", isPremium: false, isFavourite: false)
        let sticker5 = Sticker(image: #imageLiteral(resourceName: "sticker5"), title: "Later Turds", isPremium: false, isFavourite: false)
        let sticker6 = Sticker(image: #imageLiteral(resourceName: "sticker6"), title: "Later Nerds", isPremium: false, isFavourite: false)
        stickerArray = [sticker1,sticker2,sticker3,sticker4,sticker5, sticker6]
        
        let asticker1 = Sticker(image: #imageLiteral(resourceName: "aStick1"), title: "Chilling dud", isPremium: false, isFavourite: false)
        let asticker2 = Sticker(image: #imageLiteral(resourceName: "aStick2"), title: "Red Hot Pepper", isPremium: false, isFavourite: false)
        let asticker3 = Sticker(image: #imageLiteral(resourceName: "aStick3"), title: "Doggy dog Flav", isPremium: false, isFavourite: false)
        let asticker4 = Sticker(image: #imageLiteral(resourceName: "aStick4"), title: "NY", isPremium: false, isFavourite: false)
        let asticker5 = Sticker(image: #imageLiteral(resourceName: "aStick5"), title: "Honolulu", isPremium: false, isFavourite: false)
        let asticker6 = Sticker(image: #imageLiteral(resourceName: "sticker6"), title: "Later Nerds", isPremium: false, isFavourite: false)
        secondStickerArray = [asticker1,asticker2,asticker3,asticker4,asticker5, asticker6]
    }

    @objc
    private func cancelBarButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
   
    @objc
    private func savedBarButtonTapped() {
     let savedStickerVC = SavedStickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
     navigationController?.pushViewController(savedStickerVC, animated: true)
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentSegment == 0 {
            return stickerArray.count
        } else if currentSegment == 1 {
            return secondStickerArray.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: stickerCellIdentifier, for: indexPath) as! StickerCell
        
        switch currentSegment {
        case 0:
            let image = stickerArray[indexPath.item].image
            let title = stickerArray[indexPath.item].title
            cell.stickerTitle.text = title
            cell.stickerImageView.image = image
        case 1:
            let image = secondStickerArray[indexPath.item].image
            let title = secondStickerArray[indexPath.item].title
            cell.stickerTitle.text = title
            cell.stickerImageView.image = image
        default:
            break
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image:UIImage?
        switch currentSegment {
        case 0:
             image = stickerArray[indexPath.item].image
        case 1:
             image = secondStickerArray[indexPath.item].image
        default:
            break
        }
        guard image != nil else {return}
        delegate?.didSelectSticker(image!)
        dismiss(animated: true, completion: nil)

    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let stickerHeaderCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stickerHeaderCellIdentier, for: indexPath) as! StickerHeaderCell
        stickerHeaderCell.delegate = self
        if isInitialLoad {
            stickerHeaderCell.stickerSegmentControl.selectedSegmentIndex = 0
            isInitialLoad = false
        }
        return stickerHeaderCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
}

extension StickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 6) / 2
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension StickerViewController: StickerHeaderCellDelegate {
    
    func didTapSegment(_ segment: Int) {
        currentSegment = segment
        collectionView?.reloadData()
    }
}




