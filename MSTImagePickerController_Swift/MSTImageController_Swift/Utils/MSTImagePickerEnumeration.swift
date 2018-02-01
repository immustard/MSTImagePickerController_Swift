//
//  MSTImagePickerEnumeration.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/11.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

 public enum MSTImagePickerAccessType: Int {
    case photosWithoutAlbums    // 无相册界面, 但直接进入相册胶卷
    case photosWithAlbums       // 有相册界面, 但直接进入相册胶卷
    case albums                 // 直接进入相册界面
}

public enum MSTImagePickerSourceType: Int {
    case photo
    case camera
    case sound
}

public enum MSTAuthorizationStatus: Int {
    case notDetermined      // 未知
    case restricted         // 受限制
    case denied             // 拒绝
    case authorized         // 授权
}

public enum MSTImageMomentGroupType: Int {
    case none
    case year
    case month
    case day
}

public enum MSTImagePickerStyle: Int {
    case light
    case dark
}
