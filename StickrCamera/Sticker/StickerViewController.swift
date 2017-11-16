//
//  StickerViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol ChooseStickerDelegate: class {
    func didChooseSticker(_ image:UIImage)
}


class StickerViewController: UICollectionViewController {
    
    private let stickerCellIdentifier = "StickerCell"
    
    private let stickerHeaderCellIdentier = "StickerHeaderCell"
    
    private var travelStickers = [Sticker]()
    
    private var memeStickers = [Sticker]()
    
    private var currentSegment = 0
    
    private var isInitialLoad = true
    
    var imageToEdit:UIImage?
    
    weak var delegate:ChooseStickerDelegate?

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
        
        travelStickers =  CreateSticker.travelStickers()
        memeStickers = CreateSticker.memeStickers()
        
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
            return travelStickers.count
        } else if currentSegment == 1 {
            return memeStickers.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: stickerCellIdentifier, for: indexPath) as! StickerCell
        
        switch currentSegment {
        case 0:
            let travelSticker = travelStickers[indexPath.item]
            cell.sticker = travelSticker
        case 1:
            cell.sticker = memeStickers[indexPath.item]
        default:
            break
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image:UIImage?
        switch currentSegment {
        case 0:
             image = travelStickers[indexPath.item].image
        case 1:
             image = memeStickers[indexPath.item].image
        default:
            break
        }
        guard let stickerImage = image else {return}
        delegate?.didChooseSticker(stickerImage)
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




