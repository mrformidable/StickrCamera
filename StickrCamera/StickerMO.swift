//
//  StickerMO.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-14.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class StickerMO: NSManagedObject {
   
    @NSManaged var image: Data?
    @NSManaged var title: String?
    @NSManaged var isPremium: NSNumber?
    @NSManaged var isFavourite: NSNumber?
    
}

