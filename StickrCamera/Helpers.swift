//
//  Helpers.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-03.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

public enum AdAppIdentifiers:String {
    case filterAd = "ca-app-pub-3054229073481845/2832210036"
    case stickerAd = "ca-app-pub-3054229073481845/9741055701"
    case bannerAd = "ca-app-pub-3054229073481845/5047966377"
}

public struct AccountStatus {
    static func returnUserPremiumStatus() -> Bool {
        let unlockedPremiumState = UserDefaults.standard.bool(forKey: "unlockPremiumPurchaseMade")
        return unlockedPremiumState
    }
    
    static func returnUserAdRemovalStatus() -> Bool {
        let removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
        return removeAdsPurchaseMade
    }
}

public func resizeImage(image: UIImage, ratio:CGFloat) -> UIImage {
    let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
    UIGraphicsBeginImageContext(resizedSize)
    image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage!
}

public func getImageFromRendering(with imageView:UIImageView, controllerView:UIView, topContainerView:UIView) -> UIImage? {
    
    guard let keyWindow = UIApplication.shared.keyWindow else {
        //completionHandler(false)
        return nil
    }
    let blackOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: 60))
    blackOverlayView.backgroundColor = .black

    let bottomDarkOverlay = UIView(frame: CGRect(x: 0, y: keyWindow.frame.height - 100, width: keyWindow.frame.width, height: 100))
    bottomDarkOverlay.backgroundColor = .black
    keyWindow.addSubview(bottomDarkOverlay)
    
    
    imageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height - 100)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true

    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale); // reconsider size property for your screenshot
    keyWindow.layer.render(in: UIGraphicsGetCurrentContext()!)
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    blackOverlayView.removeFromSuperview()
    bottomDarkOverlay.removeFromSuperview()
    
    return screenshot
}

extension UIView {
    
    func anchorConstraints(topAnchor: NSLayoutYAxisAnchor?, topConstant:CGFloat, leftAnchor: NSLayoutXAxisAnchor?,leftConstant:CGFloat ,rightAnchor:NSLayoutXAxisAnchor?, rightConstant: CGFloat,bottomAnchor: NSLayoutYAxisAnchor?, bottomConstant: CGFloat, heightConstant:CGFloat, widthConstant:CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = topAnchor {
            self.topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let left = leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        if let right = rightAnchor {
            self.rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
        if let bottom = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        if heightConstant > 0 {
            self.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
        if widthConstant > 0 {
            self.widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
    }
    
    func anchorCenterConstraints(centerXAnchor:NSLayoutXAxisAnchor?, xConstant:CGFloat, centerYAnchor:NSLayoutYAxisAnchor?, yConstant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let centerX = centerXAnchor {
            
            self.centerXAnchor.constraint(equalTo: centerX, constant: xConstant).isActive = true
        }
        if let centerY = centerYAnchor {
            
            self.centerYAnchor.constraint(equalTo: centerY, constant: yConstant).isActive = true
        }
    }
}
