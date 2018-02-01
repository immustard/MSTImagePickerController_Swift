//
//  MSTAlbumModel.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/13.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import Photos

internal class MSTAlbumModel: NSObject {
    var albumName: String = ""
    
    var isCameraRoll: Bool = false
    
    var count: Int {
        get {
            return self.content.count
        }
    }
    
    var content: PHFetchResult<PHAsset>! {
        didSet {
            MSTPhotoManager.shared().getMSTAssetModel(fetchResult: content) { (models) in
                self.models = models
            }
        }
    }
    
    var models: Array<MSTAssetModel> = []
}
