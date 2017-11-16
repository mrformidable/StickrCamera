//
//  CustomAlertView.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-14.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    func didTapUnlockPremiumButton()
}

protocol CustomMessageViewDelegate: class {
    func didTapRemoveAdsButton()
    func didTapRestorePurchasesButton()

}

protocol CustomMessageCameraVCDelegate: class {
    func didTapDismissButton()
    func didTapOpenSettingsButton()
}

class CustomAlertView:UIView {
    
    fileprivate lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        let containerHeight:CGFloat =  frame.height * 0.45
        
        var adjustedContainerHeight:CGFloat = 0
        
        if containerHeight < 257 {
            adjustedContainerHeight = 280
        } else {
            adjustedContainerHeight = containerHeight
        }
        
        // check if IphoneX
        if frame.height == 812 {
            adjustedContainerHeight = 300
        }
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width - 40, height: adjustedContainerHeight)
        containerView.center = self.center
        containerView.center.y = 1000
        return containerView
    }()
    
    fileprivate lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        backgroundView.frame = frame
        backgroundView.alpha = 0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBackgroundView)))
        return backgroundView
    }()
    
    lazy var alertTitleLabel:UILabel = {
        let label = UILabel()
        let rationToSubtract =  (40 / frame.width) * frame.width
        label.frame = CGRect(x: 20, y: 4
            , width: self.containerView.frame.width - rationToSubtract, height: 230)
        label.text = "Upgrading to a premium account allows you to unlock and use all stickers forever. Ads are also removed so you can enjoy the app without any interuptions."
        label.textAlignment = .center
        let fontSize = fontSizeToUse(for: frame.width)
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var actionButton:UIButton = {
        let button = UIButton()
        let rationToSubtract =  (40 / frame.width) * frame.width
        let height:CGFloat = frame.width * 0.13333
        button.frame = CGRect(x: 20, y: self.containerView.frame.height / 2 - (height / 2) + 60, width: self.containerView.frame.width - rationToSubtract, height: height)
        
        let fontSize = fontSizeToUse(for: frame.width)
        
        let attributes = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor:UIColor.white]
        let attributedTitle = NSMutableAttributedString(string: "Unlock Premum", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.layer.cornerRadius = height / 2
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(unlockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var cancelButton:UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 20, y: self.actionButton.frame.origin.y + self.actionButton.frame.height + 10 , width: self.containerView.frame.width - 50, height: 30)
        let attributes = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor:UIColor.lightGray]
        let attributedTitle = NSMutableAttributedString(string: "CANCEL", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CustomAlertViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAlert()
    }
    
    func fontSizeToUse(for viewFrame:CGFloat) -> CGFloat {
        var fontSize:CGFloat = 16
        switch viewFrame {
        case 320.0:
            fontSize = 16
        case 375.0:
            fontSize = 20
        case 414:
            fontSize = 22
        default:
            break
        }
        return fontSize
    }
    
    func setupAlert(){
        
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(alertTitleLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(cancelButton)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 1
            self.containerView.center.y = self.center.y
        }, completion: nil)
        
    }
    
    @objc fileprivate func dismissBackgroundView() {
        removeAlert()
    }
    @objc fileprivate func cancelButtonTapped(){
        removeAlert()
    }
    @objc fileprivate func unlockButtonTapped(){
        delegate?.didTapUnlockPremiumButton()
        removeAlert()
    }
    
    private func removeAlert() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 0
            self.containerView.center.y = 900
        }, completion: { (_) in
            self.backgroundView.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class CustomMessageBox: UIView {
    
    fileprivate lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        let containerHeight:CGFloat =  frame.height * 0.45
        
        var adjustedContainerHeight:CGFloat = 0
        
        if containerHeight < 257 {
            adjustedContainerHeight = 280
        } else {
            adjustedContainerHeight = containerHeight
        }
        
        // check if IphoneX
        if frame.height == 812 {
            adjustedContainerHeight = 300
        }
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width - 40, height: 180)
        containerView.center = self.center
        containerView.center.y = 1000
        return containerView
    }()
    
    fileprivate lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        backgroundView.frame = frame
        backgroundView.alpha = 0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBackgroundView)))
        return backgroundView
    }()
    
    lazy var alertTitleLabel:UILabel = {
        let label = UILabel()
        let rationToSubtract =  (40 / frame.width) * frame.width
        label.frame = CGRect(x: 20, y: 0
            , width: self.containerView.frame.width - rationToSubtract, height: 100)
        label.text = "Don't like seeing ads, remove all ads with a one time purchase"
        label.textAlignment = .center
        let fontSize = fontSizeToUse(for: frame.width)
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var actionButton:UIButton = {
        let button = UIButton()
        let rationToSubtract =  (40 / frame.width) * frame.width
        let height:CGFloat = frame.width * 0.13333
        button.frame = CGRect(x: 20, y: self.containerView.frame.height / 2 - (height / 2) + 15 , width: self.containerView.frame.width - rationToSubtract, height: height)
        
        let fontSize = fontSizeToUse(for: frame.width)
        
        let attributes = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor:UIColor.white]
        let attributedTitle = NSMutableAttributedString(string: "Remove Ads", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.layer.cornerRadius = height / 2
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return button
    }()
    
     lazy var cancelButton:UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 20, y: self.actionButton.frame.origin.y + self.actionButton.frame.height + 10 , width: self.containerView.frame.width - 50, height: 30)
        let attributes = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor:UIColor.lightGray]
        let attributedTitle = NSMutableAttributedString(string: "CANCEL", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CustomMessageViewDelegate?
    
    weak var messageViewCameraVCDelegate:CustomMessageCameraVCDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAlert()
    }
    
    func fontSizeToUse(for viewFrame:CGFloat) -> CGFloat {
        var fontSize:CGFloat = 16
        switch viewFrame {
        case 320.0:
            fontSize = 16
        case 375.0:
            fontSize = 20
        case 414:
            fontSize = 22
        default:
            break
        }
        return fontSize
    }
    
    func setupAlert(){
        
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(alertTitleLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(cancelButton)
        //
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 1
            self.containerView.center.y = self.center.y
        }, completion: nil)
        
    }
    
    @objc fileprivate func dismissBackgroundView() {
        removeAlert()
    }
    @objc fileprivate func cancelButtonTapped(){
        removeAlert()
    }
    @objc fileprivate func didTapActionButton(){
        guard let buttonTitle = actionButton.titleLabel?.text else {
            return
        }
        
        if buttonTitle == "Remove Ads" {
            delegate?.didTapRemoveAdsButton()
        } else if buttonTitle == "Restore Purchases" {
            delegate?.didTapRestorePurchasesButton()
        } else if buttonTitle == "Okay Done" {
            messageViewCameraVCDelegate?.didTapDismissButton()
        } else if buttonTitle == "Open Settings" {
            messageViewCameraVCDelegate?.didTapOpenSettingsButton()
        }
        
        removeAlert()
    }
    
    private func removeAlert() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 0
            self.containerView.center.y = 900
        }, completion: { (_) in
            self.backgroundView.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







