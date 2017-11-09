//
//  Helpers.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-03.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

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
