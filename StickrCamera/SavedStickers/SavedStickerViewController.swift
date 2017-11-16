//
//  SavedStickerViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-06.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import CoreData

class SavedStickerViewController: UICollectionViewController {
  
    private let savedCellIdentifier = "SavedStickerCell"
    
    var savedStickers = [SavedSticker]()
    
    private var managedObjContext: NSManagedObjectContext!
    
    private lazy var rightBarButton:UIBarButtonItem = {
        let rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action:  #selector(editBarButtonTapped))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
        return rightBarButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0)
        }
        collectionView?.backgroundColor = UIColor.groupTableViewBackground
        collectionView?.register(SavedStickerCell.self, forCellWithReuseIdentifier: savedCellIdentifier)
        navigationItem.title = "Saved"
        navigationItem.rightBarButtonItem = rightBarButton

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let managedObjContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        self.managedObjContext = managedObjContext
     
        let fetchRequest = NSFetchRequest<SavedSticker>(entityName: "SavedSticker")
        do {
            let savedStickers = try managedObjContext.fetch(fetchRequest)
            self.savedStickers = savedStickers
            
        } catch {
            print(error.localizedDescription)
        }
        
        print(savedStickers.count)
        
    }
    
    @objc
    private func editBarButtonTapped() {
        print("edit tapped")
        rightBarButton.title = "Done"
        NotificationCenter.default.post(name: NSNotification.Name.init("showDeleteButton"), object: nil)
    }
    
    @objc
    private func backBarButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedStickers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: savedCellIdentifier, for: indexPath) as! SavedStickerCell
        cell.savedSticker = savedStickers[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension SavedStickerViewController: UICollectionViewDelegateFlowLayout {
    
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

extension SavedStickerViewController: SavedStickerDelegate {
    func didTapDeleteButton(for cell: SavedStickerCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            fatalError("Failure to get index path")
        }
        savedStickers.remove(at: indexPath.item)
        collectionView?.deleteItems(at: [indexPath])
        let fetchRequest = NSFetchRequest<SavedSticker>(entityName: "SavedSticker")
        guard let objects = try? managedObjContext.fetch(fetchRequest) else {
            return
        }
        let objectToDelete = objects[indexPath.item] as NSManagedObject
        managedObjContext.delete(objectToDelete)
        
        do {
            try managedObjContext.save()
            print("saved, show alert here also")
        } catch {
            print(error.localizedDescription)
        }
    }
    
}











