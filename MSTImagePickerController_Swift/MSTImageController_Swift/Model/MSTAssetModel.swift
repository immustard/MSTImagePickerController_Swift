//
//  MSTAssetModel.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/13.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import Photos

public class MSTAssetModel: MSTAssetBaseModel {
    var asset: PHAsset!
    
    class func model(_ asset: PHAsset) -> MSTAssetModel {
        let model: MSTAssetModel = MSTAssetModel()
        
        model.asset = asset
        
        return model
    }
    
    var isSelected: Bool = false
    
    override var identifier: String {
        return asset.localIdentifier
    }
    
    override var type: MSTAssetModelMediaType {
        if #available(iOS 9.1, *) {
            guard asset.mediaSubtypes != .photoLive else {
                return .livePhoto
            }
        }
        
        switch asset.mediaType {
        case .image:
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        default:
            return .unknown
        }
    }
    
    override var videoDuration: TimeInterval {
        if type == .video {
            return asset.duration
        } else {
            return 0
        }
    }
}
