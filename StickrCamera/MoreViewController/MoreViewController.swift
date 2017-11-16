//
//  MoreViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-13.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    private let cellIdentifier = "MoreCell"
    
    private let topBarContainerView = UIView()
    
    private let accountLabels = ["Unlock Premium", "Remove Ads", "Share"]
    
    private let iapSharedInstance = IAPHelper.sharedInstance
    
    private lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: UITableViewStyle.plain)
        tb.delegate = self
        tb.dataSource = self
        tb.isScrollEnabled = false
        tb.backgroundColor = UIColor.groupTableViewBackground
        return tb
    }()
    
    private lazy var backButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "camera_icon"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let logoContainerView:UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "stikcr_icon"))
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        iapSharedInstance.getIapProducts()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.backgroundColor = .white
        topBarContainerView.backgroundColor = .white
        
        view.addSubview(topBarContainerView)
        view.addSubview(logoContainerView)
        view.addSubview(tableView)
        topBarContainerView.addSubview(backButton)
        
        if #available(iOS 11, *) {
            topBarContainerView.anchorConstraints(topAnchor: view.safeAreaLayoutGuide.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 40, widthConstant: 0)
        } else {
            topBarContainerView.anchorConstraints(topAnchor: view.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 40, widthConstant: 0)
        }
        
        backButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: topBarContainerView.rightAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 25, widthConstant: 25)
        backButton.centerYAnchor.constraint(equalTo: topBarContainerView.centerYAnchor, constant: 0).isActive = true
        
        
        logoContainerView.anchorConstraints(topAnchor: topBarContainerView.bottomAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: tableView.topAnchor, bottomConstant: 0, heightConstant: 200, widthConstant: 0)
        
        tableView.anchorConstraints(topAnchor: logoContainerView.bottomAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: view.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.groupTableViewBackground
        tableView.tableFooterView = bottomView
        
        let navTitle = UILabel()
        navTitle.text = "More"
        navTitle.font = .boldSystemFont(ofSize: 16)
        topBarContainerView.addSubview(navTitle)
        navTitle.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 25, widthConstant: 40)
        navTitle.anchorCenterConstraints(centerXAnchor: topBarContainerView.centerXAnchor, xConstant: 0, centerYAnchor: topBarContainerView.centerYAnchor, yConstant: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFailedRestorePurchases), name: NSNotification.Name.init("HandleFailedRestorePurchasesNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCompletedRestoredPurchases), name: NSNotification.Name.init("CompletedRestorePurchasesNotification"), object: nil)
        
    }
    
    @objc
    private func handleFailedRestorePurchases() {
        print("show alert here")
        let messageView = CustomMessageBox(frame: view.frame)
        messageView.alertTitleLabel.text = "There are no purchases to restore on this iCloud account"
        let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
        let attributedTitle = NSMutableAttributedString(string: "Okay", attributes: attributes)
        messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
        messageView.cancelButton.isHidden = true
        view.addSubview(messageView)
    }
    
    @objc
    private func handleCompletedRestoredPurchases() {
        let messageView = CustomMessageBox(frame: view.frame)
        messageView.alertTitleLabel.text = "You have successfully restored purchases"
        messageView.cancelButton.isHidden = true
        let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
        let attributedTitle = NSMutableAttributedString(string: "Okay", attributes: attributes)
        messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
        view.addSubview(messageView)
        print("show completing alert here")
    }
    
    @objc
    private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        let titleLabel = UILabel()
        
        if section == 0 {
            titleLabel.text = "Account"
        } else {
            titleLabel.text = "Purchases"
        }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(titleLabel)
        titleLabel.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 10, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }
}

extension MoreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return accountLabels.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = accountLabels[indexPath.row]
        } else {
            cell.textLabel?.text = "Restore Purchases"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Account"
        } else {
            return "Purchases"
        }
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let alertView = CustomAlertView(frame: view.frame)
                alertView.delegate = self
                view.addSubview(alertView)
            } else if indexPath.row == 1 {
                let messageView = CustomMessageBox(frame: view.frame)
                messageView.delegate = self
                view.addSubview(messageView)
            } else {
                let appUrlShareLink = "some link to share app"
                let activityController = UIActivityViewController(activityItems: [appUrlShareLink], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
            
        } else {
            let messageView = CustomMessageBox(frame: view.frame)
            messageView.alertTitleLabel.text = "You can restore purchases you have previously made."
            let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
            let attributedTitle = NSMutableAttributedString(string: "Restore Purchases", attributes: attributes)
            messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
            messageView.actionButton.setTitle("Restore Purchases", for: .normal)
            messageView.delegate = self
            view.addSubview(messageView)
        }
    }
}

extension MoreViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimationPresentor()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimationDismissor()
    }
}

extension MoreViewController: CustomAlertViewDelegate {
    func didTapUnlockPremiumButton() {
        iapSharedInstance.purchaseProduct(product: .unlockPremiumProduct)
    }
}

extension MoreViewController: CustomMessageViewDelegate {
    func didTapRemoveAdsButton() {
        iapSharedInstance.purchaseProduct(product: .removeAdsProduct)
    }
    func didTapRestorePurchasesButton() {
        iapSharedInstance.restorePurchases()
    }
}


