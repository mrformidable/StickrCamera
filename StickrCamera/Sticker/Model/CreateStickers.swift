//
//  CreateStickers.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-04.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import Foundation



struct CreateSticker {
    
    
    static func generateStickers2() -> [Sticker] {
        var array = [Sticker]()
        let asticker1 = Sticker(image: #imageLiteral(resourceName: "aStick1"), title: "Chilling dud", isPremium: false, isFavourite: false)
        let asticker2 = Sticker(image: #imageLiteral(resourceName: "aStick2"), title: "Red Hot Pepper", isPremium: false, isFavourite: false)
        let asticker3 = Sticker(image: #imageLiteral(resourceName: "aStick3"), title: "Doggy dog Flav", isPremium: false, isFavourite: false)
        let asticker4 = Sticker(image: #imageLiteral(resourceName: "aStick4"), title: "NY", isPremium: false, isFavourite: false)
        let asticker5 = Sticker(image: #imageLiteral(resourceName: "aStick5"), title: "Honolulu", isPremium: false, isFavourite: false)
        let asticker6 = Sticker(image: #imageLiteral(resourceName: "sticker6"), title: "Later Nerds", isPremium: false, isFavourite: false)
        array = [asticker1,asticker2,asticker3,asticker4,asticker5, asticker6]
        return array
    }
    
    static func memeStickers() -> [Sticker] {
        var stickers = [Sticker]()
        let angryMeme = Sticker(image: #imageLiteral(resourceName: "angry_meme"), title: "Angry Face", isPremium: true, isFavourite: false)
        let annoyedMeme =  Sticker(image: #imageLiteral(resourceName: "annoyed"), title: "Annoyed Face", isPremium: true, isFavourite: false)
        let confusedGirlMeme =  Sticker(image: #imageLiteral(resourceName: "confused_girl_meme"), title: "Confused Girl", isPremium: true, isFavourite: false)
        let cutenessOverloadMeme =  Sticker(image: #imageLiteral(resourceName: "Happy-cuteness-overload"), title: "Cuteness Overload", isPremium: true, isFavourite: false)
        let pepeMeme =  Sticker(image: #imageLiteral(resourceName: "pepe_meme"), title: "Pepe The Frog", isPremium: true, isFavourite: false)
        let suspiciousMeme =  Sticker(image: #imageLiteral(resourceName: "suspicious_look"), title: "Suspicous Look", isPremium: true, isFavourite: false)
        let trollFaceMeme =  Sticker(image: #imageLiteral(resourceName: "trollFace"), title: "Troll Face", isPremium: true, isFavourite: false)
        let yeahMeme =  Sticker(image: #imageLiteral(resourceName: "yeah"), title: "Yeahh Meme", isPremium: true, isFavourite: false)
        stickers = [angryMeme, annoyedMeme, confusedGirlMeme, cutenessOverloadMeme, pepeMeme, suspiciousMeme, trollFaceMeme, yeahMeme]
        
        return stickers
    }
    
    static func travelStickers() -> [Sticker] {
        var stickers = [Sticker]()
        let iLoveToronto = Sticker(image: #imageLiteral(resourceName: "i_love_to"), title: "I Love Toronto", isPremium: true, isFavourite: false)
        let volkswagenSticker =  Sticker(image: #imageLiteral(resourceName: "volkswagen"), title: "Road Trip", isPremium: true, isFavourite: false)
        let torontoLoveSticker =  Sticker(image: #imageLiteral(resourceName: "toronto"), title: "I love Toronto ", isPremium: true, isFavourite: false)
        stickers = [iLoveToronto, volkswagenSticker, torontoLoveSticker]
        
        return stickers
    }
}
