//
//  CreateStickers.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-04.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import Foundation

public struct CreateSticker {
    static func sampleStickers() -> [Sticker] {
        var array = [Sticker]()
        let sendNoods = Sticker(image: #imageLiteral(resourceName: "sticker"), title: "Chilling dud", isPremium: false, isFavourite: false)
        let newYork = Sticker(image: #imageLiteral(resourceName: "nyStick"), title: "NY", isPremium: false, isFavourite: false)
        let hawaiiSticker = Sticker(image: #imageLiteral(resourceName: "hawaii"), title: "Honolulu", isPremium: false, isFavourite: false)
        let angryMeme = Sticker(image: #imageLiteral(resourceName: "angry_meme"), title: "Angry Face", isPremium: false, isFavourite: false)
        array = [sendNoods,angryMeme,newYork,hawaiiSticker]
        return array
    }
    
    static func memeStickers() -> [Sticker] {
        var stickers = [Sticker]()
        let annoyedMeme =  Sticker(image: #imageLiteral(resourceName: "annoyed"), title: "Annoyed Face", isPremium: true, isFavourite: false)
        let confusedGirlMeme =  Sticker(image: #imageLiteral(resourceName: "confused_girl_meme"), title: "Confused Girl", isPremium: true, isFavourite: false)
        let cutenessOverloadMeme =  Sticker(image: #imageLiteral(resourceName: "Happy-cuteness-overload"), title: "Cuteness Overload", isPremium: true, isFavourite: false)
        let youDontSayMeme =  Sticker(image: #imageLiteral(resourceName: "youDontSayMeme"), title: "You Don't Say", isPremium: true, isFavourite: false)
        let suspiciousMeme =  Sticker(image: #imageLiteral(resourceName: "suspicious_look"), title: "Suspicous Look", isPremium: true, isFavourite: false)
        let trollFaceMeme =  Sticker(image: #imageLiteral(resourceName: "trollFace"), title: "Troll Face", isPremium: true, isFavourite: false)
        let yeahMeme =  Sticker(image: #imageLiteral(resourceName: "yeah"), title: "Yeahh Meme", isPremium: true, isFavourite: false)
        let arthurMeme =  Sticker(image: #imageLiteral(resourceName: "arthurMeme"), title: "Arthur Meme", isPremium: true, isFavourite: false)
        let confusedTroll =  Sticker(image: #imageLiteral(resourceName: "angryFace"), title: "Confused Troll", isPremium: true, isFavourite: false)
        let rainbowPukeMeme =  Sticker(image: #imageLiteral(resourceName: "pukingRainbow"), title: "Puking Rainbow", isPremium: true, isFavourite: false)

        stickers = [ annoyedMeme, confusedGirlMeme, cutenessOverloadMeme, youDontSayMeme, suspiciousMeme, trollFaceMeme, yeahMeme, arthurMeme, confusedTroll, rainbowPukeMeme]
        return stickers
    }
    
    static func travelStickers() -> [Sticker] {
        var stickers = [Sticker]()
        let iLoveToronto = Sticker(image: #imageLiteral(resourceName: "i_love_to"), title: "I Love Toronto", isPremium: true, isFavourite: false)
        let volkswagenSticker =  Sticker(image: #imageLiteral(resourceName: "volkswagen"), title: " Volkswagen Road Trip", isPremium: true, isFavourite: false)
        let caliSticker =  Sticker(image: #imageLiteral(resourceName: "cali_sticker"), title: "Cali", isPremium: true, isFavourite: false)
        let exploreGlasses =  Sticker(image: #imageLiteral(resourceName: "exploreGlasses"), title: "Explore Glasses", isPremium: true, isFavourite: false)
        let barcaSticker =  Sticker(image: #imageLiteral(resourceName: "barcaE"), title: "Barcelona", isPremium: true, isFavourite: false)
        let londonBusSticker = Sticker(image: #imageLiteral(resourceName: "london_bus"), title: "London Bus", isPremium: true, isFavourite: false)
        stickers = [iLoveToronto, volkswagenSticker, caliSticker, exploreGlasses, barcaSticker, londonBusSticker]
        return stickers
    }
}
