//
//  MSTAssetBaseModel.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 27/12/2017.
//  Copyright © 2017 Mustard. All rights reserved.
//

import UIKit

enum MSTAssetModelMediaType: Int {
    case image
    case livePhoto
    case gif
    case video
    case audio
    case unknown
}

public class MSTAssetBaseModel: NSObject {
    var identifier: String {
        return ""
    }
    
    var type: MSTAssetModelMediaType {
        return .unknown
    }
    
    var videoDuration: TimeInterval {
        return 0
    }
}
