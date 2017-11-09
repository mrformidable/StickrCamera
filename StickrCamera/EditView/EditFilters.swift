//
//  Filters.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import CoreImage

public enum FilterName:String {
    case mono = "CIPhotoEffectMono"
    case tonal = "CIPhotoEffectTonal"
    case noir = "CIPhotoEffectNoir"
    case fade = "CIPhotoEffectFade"
    case chrome = "CIPhotoEffectChrome"
    case process = "CIPhotoEffectProcess"
    case transfer = "CIPhotoEffectTransfer"
    case instant = "CIPhotoEffectInstant"
    case sepia = "CISepiaTone"
}


struct Filter {
    private let filterName:FilterName!
    private let filter:CIFilter
    
    init(filterName:FilterName) {
        self.filterName = filterName
        self.filter = CIFilter(name: filterName.rawValue)!
    }
    
    func inputImage(_ image:UIImage) {
        guard let cgImage = image.cgImage else {
            print("nil cgImage");
            return
        }
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
    }
    
    func outputImage() -> UIImage? {
        guard let outputImage = filter.outputImage else { print("nil output image");return nil }
        guard let openGLContext = EAGLContext(api: .openGLES2) else {print("nil context");return nil}
        let ciImageContext = CIContext(eaglContext: openGLContext)
        guard let newCGImage = ciImageContext.createCGImage(outputImage, from: outputImage.extent) else {print("nil new Image");return nil}
        return UIImage(cgImage: newCGImage)
    }
}

struct ExposureFilter {
    
    static func exposureFilter(_ inputImage:UIImage) -> UIImage? {
        let exposureFilter = Filter(filterName: .chrome)
        exposureFilter.inputImage(inputImage)
        return exposureFilter.outputImage()
    }
}

//struct SaturationFilter {
//    
//    let saturation = Filter(filterName: "CIColorControls")
//
//    func saturation(_ exposure: Float) {
//        self.saturation?.filter.setValue(exposure, forKey: kCIInputSaturationKey)
//    }
//    func outputImage() -> UIImage? {
//        return self.saturation?.outputImage()
//    }
//    func inputpImage(_ image:UIImage) {
//        self.saturation?.inputImage(image)
//    }
//    
//}






