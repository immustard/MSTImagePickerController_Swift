//
//  MSTPhotoConfiguration.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/11.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

public class MSTPhotoConfiguration: NSObject {
    // 是否多选
    var isMutiSelected: Bool = true

    // 最大选择个数，只在多选(mutiSelected)为 true 时可用
    var maxSelectCount: Int = 9
    
    // 获取的图片最大宽度，当选定『原图』时，该值无效。
    // 该值最小为 720
    var maxImageWidth: CGFloat = 828
    
    // 一行显示多少个
    var numsInRow: Int = 4
    
    // 是否有蒙版
    var HasMasking: Bool = true
    
    // 选中动画, iOS9 以下不可用
    var HasSelectAnimation: Bool = true

    
    // 显示主题
    var themeStyle: MSTImagePickerStyle = .light
    
    // 主题颜色_正常
    var themeColor: UIColor = UIColor(red: 0.36, green: 0.79, blue: 0.96, alpha: 1)
    
    // 主题颜色_浅
    var themeLightColor: UIColor = UIColor(red: 0.65, green: 0.82, blue: 0.88, alpha: 1)
    
    // 图片分组类型
    var photoMomentGroupType: MSTImageMomentGroupType = .none
    
    // 图片是否为降序排列
    var isPhotosDesc: Bool = true
    
    // 是否显示相册缩略图
    var hasAlbumThumbnail: Bool = true
    
    // 是否显示相册包含图片个数
    var hasPhotosCount: Bool = true
    
    // 是否显示空相册
    var hasEmptyAlbum: Bool = false
    
    // 是否只显示图片
    var isOnlyShowImages: Bool = false
    
    // 是否显示 Live Photo 图标
    var hasLivePhotoIcon: Bool = true
    
    // 是否返回 Live Photo
    var callbackLivePhoto: Bool = true
    
    // 是否允许选择原图
    var isAllowOriginImage: Bool = true
    
    // 第一个图标是否为相机
    var isFirstCamera: Bool = true
    
    // 缩略图界面, 相机 cell 是否为动态
    // 仅当 "firstCamera" 为 ture 时生效
    // 当该属性生效时, 界面可能出现卡顿
    var isDynamicCamera: Bool = false
    
    // 是否可以录制视频
    var hasMakingVideo: Bool = true
    
    // 视频录制后, 是否自动保存到系统相册
    // 当有自定义相册名称 "cumstomAlbumName" 时, 保存到该相册
    // 仅当 "madingVideo" 为 ture 时生效
    var isVideoAutoSave: Bool = true
    
    // 允许选择动图
    var pickGif: Bool = true
    
    // 视频录制最大时间
    var videoMaxDuration: TimeInterval = 60
    
    // 自动 dismiss
    var isAutoDismiss: Bool = true
    
    // 自定义相册名称, 为空时保存到系统相册
    // 不为空时, 系统中没有该相册, 则自动创建
    var customAlbumName: String?
    
    // 相册缩略图
    var placeholderThumbnail: UIImage?
    
    // 照片选中按钮, 未选择图片
    var photoPickNormalImage: UIImage?
    
    // 照片选中按钮, 已选择图片
    var photoPickSelectedImage: UIImage?
    
    // 缩略图界面, camera cell 显示图片
    var cameraImage: UIImage?
    
    // 是否国际化
    var isLocalizedString: Bool = true
    
    // 单例方法
    class func shared() -> MSTPhotoConfiguration {
        struct Static {
            static let instance = MSTPhotoConfiguration()
        }
        
        return Static.instance
    }
    
    // 缩略图界面显示宽度
    internal var gridWidth: CGFloat {
        return (kScreenWidth-self.gridPadding)/CGFloat(self.numsInRow) - self.gridPadding
    }
    
    // 缩略图界面边缘宽度
    internal var gridPadding: CGFloat {
        return 4
    }
}
