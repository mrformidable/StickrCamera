//
//  FilterViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-08.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol FilterViewControllerDelegate: class {
    func didChooseFilter(_ image:UIImage)
}


class FilterViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    var image: UIImage?
    
    var thumbnailImage: UIImage?
    
    var editedImage: UIImage?
    
    weak var delegate: FilterViewControllerDelegate?
    
    private let cellIdentifier = "FilterCell"
    
    let unlockedPremiumState = UserDefaults.standard.bool(forKey: "unlockPremiumPurchaseMade")
    
    let removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
    
    private lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private var interstitial:GADInterstitial!
    
    let filters = [Filter(filterName: .none),
                   Filter(filterName: .sepia),
                   Filter(filterName: .tonal),
                   Filter(filterName: .noir),
                   Filter(filterName: .fade),
                   Filter(filterName: .chrome),
                   Filter(filterName: .process),
                   Filter(filterName: .transfer),
                   Filter(filterName: .instant)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: cellIdentifier)
        containerView.addSubview(collectionView)
        collectionView.anchorConstraints(topAnchor: containerView.topAnchor, topConstant: 0, leftAnchor: containerView.leftAnchor, leftConstant: 0, rightAnchor: containerView.rightAnchor, rightConstant: 0, bottomAnchor: containerView.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        guard let image = image else {return}
        imageView.image = image
        thumbnailImage = resizeImage(image: image, ratio: 0.3)
        editedImage = resizeImage(image: image, ratio: 1.0)
        
        interstitial = createAndLoadInterstitial()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                return
            }
            showInterstitialAds()
            print("show ads here")
        }
        
        print(AccountStatus.returnUserAdRemovalStatus(), "ad status")
        print(AccountStatus.returnUserPremiumStatus(), "premium status")
    }
    
    private func showInterstitialAds() {
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
            print("error showing ad")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let image = imageView.image else { return }
        delegate?.didChooseFilter(image)
        dismiss(animated: true, completion: nil)
    }
    
  private func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: AdAppIdentifiers.filterAd.rawValue)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
}

extension FilterViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FilterCell
        cell.imageView.image = thumbnailImage
        if indexPath.item != 0 {
            if let _thumbnailImage = thumbnailImage {
                cell.imageView.image = filters[indexPath.item]?.filterImage(_thumbnailImage)
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            imageView.image = image
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                DispatchQueue.main.async { [weak self] in
                    if let _editedImage = self?.editedImage {
                        self?.imageView.image = self?.filters[indexPath.item]?.filterImage(_editedImage)
                    }
                }
            }
        }
    }
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 70, height: 70)
    }
}

extension FilterViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}




