//
//  AddStickerViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-10.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol AddStickerViewDelegate: class {
    func didSelectSticker(_ image:UIImage)
}


class AddStickerViewController: UIViewController {
    
    private let cellIdentifier = "ChooseStickerCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var topContainerView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var stickerImageView:UIImageView!
    
    weak var delegate: AddStickerViewDelegate?
    
    var image: UIImage?
    
    private var identity = CGAffineTransform.identity

    private var isRotating = false
    
    var stickers = [Sticker]()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        stickerImageView.image = #imageLiteral(resourceName: "sticker")
        gestureImplimentation()
        
        stickerImageView.frame = CGRect(x: view.frame.midX, y: view.frame.midY, width: 120, height: 120)
        
        stickers = CreateSticker.generateStickers2()
    }
    
    private func gestureImplimentation() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didBeginImageDrag(_:)))
        panGestureRecognizer.delegate = self
        stickerImageView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didBeginImagePinch(_:)))
        pinchGesture.delegate = self
        stickerImageView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didBeginImageRotation(_:)))
        rotationGesture.delegate = self
        stickerImageView.addGestureRecognizer(rotationGesture)
    }
    
  
    @IBAction func allStickersButtonTapped(_ sender: Any) {
        let stickerVC = StickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        stickerVC.delegate = self
        let navVC = UINavigationController(rootViewController: stickerVC)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc
    private func didBeginImageDrag(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: imageView)
        if !isRotating {
            stickerImageView.center = CGPoint(x: stickerImageView.center.x + point.x, y: stickerImageView.center.y + point.y)
            gesture.setTranslation(.zero, in: imageView)
        }
    }
    
    @objc
    private func didBeginImagePinch(_ gesture:UIPinchGestureRecognizer) {
        if !isRotating {
            switch gesture.state {
            case .began:
                identity = stickerImageView.transform
            case .changed,.ended:
                stickerImageView.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
            case .cancelled:
                break
            default:
                break
            }
        }
    }
    
    @objc
    private func didBeginImageRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else {  return  }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        if gesture.state == .changed || gesture.state == .began {
            isRotating = true
        }
        if gesture.state == .ended {
            isRotating = false
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        guard let selectedSticker = getImageFromRendering(with: imageView, controllerView: self.view, topContainerView: topContainerView) else {
            return
        }
        delegate?.didSelectSticker(selectedSticker)
        dismiss(animated: true, completion: nil)
    }
   
}

extension AddStickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AddStickerCell
        cell.imageView.image = stickers[indexPath.item].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sticker = stickers[indexPath.item].image
        stickerImageView.image = sticker
    }
    
}


extension AddStickerViewController: ChooseStickerDelegate {
    func didChooseSticker(_ image: UIImage) {
        stickerImageView.image = image
    }
    
}

extension AddStickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}










