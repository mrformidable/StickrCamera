//
//  StickerViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import GoogleMobileAds

public protocol ChooseStickerDelegate: class {
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
    
    private var canSelectSticker:Bool = false
    
    private var interstitial:GADInterstitial!
    
    private let iapSharedInstance = IAPHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.groupTableViewBackground
        collectionView?.register(StickerCell.self, forCellWithReuseIdentifier: stickerCellIdentifier)
        collectionView?.register(StickerHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: stickerHeaderCellIdentier)
        collectionView?.contentInset = UIEdgeInsetsMake(5, 2, 0, 2)
        
        UINavigationBar.appearance().tintColor = .black
        let leftBarButtonItem =  UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.title = "Stickers"
        
        travelStickers =  CreateSticker.travelStickers()
        memeStickers = CreateSticker.memeStickers()
        
        iapSharedInstance.getIapProducts()
        
        interstitial = createAndLoadInterstitial()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnlockPremiumPurchaseMade), name: NSNotification.Name.init("UnlockPremiumPurchaseMade"), object: nil)
        
        if AccountStatus.returnUserAdRemovalStatus() {
            print("should not show any ads")
        } else {
            print("show ads here")
            showInterstitialAds()
        }
        
        if AccountStatus.returnUserPremiumStatus() {
            print("should not show ads here")
        } else {
            if AccountStatus.returnUserAdRemovalStatus() {
                print("user paid to remove ads")
            } else {
                showInterstitialAds()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canSelectSticker = AccountStatus.returnUserPremiumStatus()

    }

    private func showInterstitialAds() {
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
            print("error showing ad")
        }
    }
    
    @objc
    private func handleUnlockPremiumPurchaseMade() {
        canSelectSticker = true
        guard let collectionViewCells = collectionView?.visibleCells else {
            print("no visible cells")
            return
        }
        for cell in collectionViewCells {
            if let stickerCell = cell as? StickerCell {
                stickerCell.lockButton.isHidden = true
            }
        }
    }
    
    @objc
    private func cancelBarButtonTapped() {
        dismiss(animated: true, completion: nil)
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
            cell.sticker = travelStickers[indexPath.item]
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
        if canSelectSticker {
            guard let stickerImage = image else {return}
            delegate?.didChooseSticker(stickerImage)
            dismiss(animated: true, completion: nil)
        } else {
            let messageAlert = CustomAlertView(frame: view.frame)
            messageAlert.alertTitleLabel.text = "Sticker Locked. It looks like you have not unlocked the premium account, To enable sticker use, please unlock premium account"
            messageAlert.delegate = self
            view.addSubview(messageAlert)
        }
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
    
    private func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: AdAppIdentifiers.filterAd.rawValue)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
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
extension StickerViewController: CustomAlertViewDelegate {
    func didTapUnlockPremiumButton() {
        iapSharedInstance.purchaseProduct(product: .unlockPremiumProduct)
    }
}

extension StickerViewController: StickerHeaderCellDelegate {
    func didTapSegment(_ segment: Int) {
        currentSegment = segment
        collectionView?.reloadData()
    }
}

extension StickerViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}



