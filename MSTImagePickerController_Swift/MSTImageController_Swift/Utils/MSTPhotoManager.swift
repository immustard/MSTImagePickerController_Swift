//
//  MSTPhotoManager.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/13.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit
import Photos

protocol MSTPhotoManagerProtocol {
    /// 单例方法
    ///
    /// - Returns: 实例
    static func shared() -> MSTPhotoManager
    
    /// 检测 App 授权
    ///
    /// - Parameters:
    ///   - type: 授权类型
    ///   - callback: 授权状态
    static func checkAuthorizationStatus(sourceType type: MSTImagePickerSourceType, callback: (@escaping (_ sourceType: MSTImagePickerSourceType, _ status: MSTAuthorizationStatus) -> Void))
    
    /// 读取 "相机胶卷" 的信息
    ///
    /// - Parameters:
    ///   - isDesc: 是否为倒序
    ///   - isShowEmpty: 是否显示空相册
    ///   - isOnlyShowImage: 是否只显示图片
    ///   - completeClosure: 回调值
    func loadCameraRollInfo(isDesc: Bool, isShowEmpty: Bool, isOnlyShowImage: Bool, completeClosure: (@escaping (_ result: MSTAlbumModel?) -> Void))
    
    /// 读取所有相册的信息
    ///
    /// - Parameters:
    ///   - isDesc: 是否为倒序
    ///   - isShowEmpty: 是否显示空相册
    ///   - isOnlyShowImage: 是否只显示图片
    ///   - completeClosure: 返回数组
    func loadAlbumInfo(isDesc: Bool, isShowEmpty: Bool, isOnlyShowImage: Bool, completeClosure: (@escaping (_ customAlbum: PHFetchResult<PHCollection>, _ albumModelsArray: Array<MSTAlbumModel>) -> Void))

    /// 保存图片到系统相册
    ///
    /// - Parameters:
    ///   - image: 待保存图片
    ///   - completeClosure: 回调
    func saveImageToSystemAlbum(_ image: UIImage, completeClosure: (@escaping (_ asset: PHAsset?, _ errStr: String) -> Void))

    /// 保存图片到自定义相册, 没有则创建
    ///
    /// - Parameters:
    ///   - image: 待保存图片
    ///   - albumName: 自定义相册名称
    ///   - completeClosure: 回调
    func saveImageToCustomAlbum(_ image: UIImage, albumName: String, completeClosure: (@escaping (_ asset: PHAsset?, _ errStr: String) -> Void))

    /// 保存视频到系统相册
    ///
    /// - Parameters:
    ///   - url: 视频URL
    ///   - completeClosure: 回调
    func saveVideoToSystemAlbum(_ url: URL, completeClosure: (@escaping (_ asset: PHAsset?, _ errStr: String) -> Void))

    /// 保存视频到自定义相册, 没有则创建
    ///
    /// - Parameters:
    ///   - url: 视频URL
    ///   - albumName: 自定义相册名称
    ///   - completeClosure: 回调
    func saveVideoToCustomAlbum(_ url: URL, albumName: String, completeClosure: (@escaping (_ asset: PHAsset?, _ errStr: String) -> Void))
    
    /// 根据时间分组排序
    ///
    /// - Parameters:
    ///   - momentType: 分组类型
    ///   - models: 传入数据
    /// - Returns: 分组结果
    func sortByMomentType(_ momentType: MSTImageMomentGroupType, assets models: Array<MSTAssetModel>) -> Array<MSTMoment>
    
    /// 根据 identifier 得到 MSTAssetModel
    ///
    /// - Parameter identifier: 标识符
    func getMSTAssetModel(identifier: String) -> MSTAssetModel
    
    /// 根据相册封装 assetModel
    ///
    /// - Parameters:
    ///   - fetchResult: 相册信息
    ///   - completeClosure: 回调
    func getMSTAssetModel(fetchResult: PHFetchResult<PHAsset>, completeClosure: (@escaping(_ models: Array<MSTAssetModel>) -> Void))
    
    /// 读取缩略图
    ///
    /// - Parameters:
    ///   - asset: 图片内容
    ///   - width: 图片宽度, 1:1, scale 默认 2.0
    ///   - completeClosure: 回调
    func thumbnailImage(asset: PHAsset, photoWidth width: CGFloat, completeClosure: (@escaping(_ result: UIImage, _ info: [AnyHashable : Any]?) -> Void))
    
    /// 读取预览图片, 宽度默认为屏幕宽度
    ///
    /// - Parameters:
    ///   - asset: 图片内容
    ///   - isHighQuality: 是否是高质量, 为 true 时, scale 为设备屏幕的 scale, false 时 scale 为 0.1
    ///   - completeClosure: 回调
    func previewImage(asset: PHAsset, isHighQuality: Bool, completeClosure: (@escaping(_ result: UIImage, _ info: [AnyHashable : Any]?, _ isDegraded: Bool) -> Void))
    
    /// 读取 Live Photo
    ///
    /// - Parameters:
    ///   - asset: live photo 内容
    ///   - completeClosure: 回调
    @available(iOS 9.1, *)
    func livePhoto(asset: PHAsset, completeClosure: (@escaping(_ livePhoto: PHLivePhoto, _ isDegraded: Bool) -> Void))
    
    /// 读取选定照片
    ///
    /// - Parameters:
    ///   - asset: 图片内容
    ///   - isFullImage: 是否为原图
    ///   - width: 最大图片宽度, isFullImage 为 flase 时生效
    ///   - completeClosure: 回调
    func pickingImage(asset: PHAsset, isFullImage: Bool, maxImageWidth width: CGFloat, completeClosure: (@escaping(_ result: UIImage, _ info: [AnyHashable : Any]?, _ isDegraded: Bool) -> Void))
    
    /// 读取视频
    ///
    /// - Parameters:
    ///   - asset: 视频内容
    ///   - completeClosure: 回调
    func avPlayerItem(asset: PHAsset, completeClosure: (@escaping(_ item: AVPlayerItem) -> Void))
    
    /// 图片的大小
    ///
    /// - Parameters:
    ///   - models: 图片内容
    ///   - completeClosure: 回调
    func imageBytes(models: Array<MSTAssetModel>, completeClosure: (@escaping(_ result: String) -> Void))
}

class MSTPhotoManager: NSObject, MSTPhotoManagerProtocol {
    
    // MARK: - Properties
    private var imageManager: PHImageManager = PHImageManager.default()

    // MARK: - Class Methods
    public class func shared() -> MSTPhotoManager {
        struct Static {
            static let instance = MSTPhotoManager()
        }
        
        return Static.instance
    }
    
    static func checkAuthorizationStatus(sourceType type: MSTImagePickerSourceType, callback: @escaping ((MSTImagePickerSourceType, MSTAuthorizationStatus) -> Void)) {
        switch type {
        case .photo:
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    callback(type, MSTAuthorizationStatus(rawValue: status.rawValue)!)
                })
            } else {
                callback(type, MSTAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!)
            }
        case .camera: break
        case .sound: break
        }
    }
    
    // MARK: - Instance Methods
    func loadCameraRollInfo(isDesc: Bool, isShowEmpty: Bool, isOnlyShowImage: Bool, completeClosure: @escaping ((MSTAlbumModel?) -> Void)) {
        let albumCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        albumCollection.enumerateObjects { (obj, idx, stop) in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !isDesc)]
            
            if isOnlyShowImage {
                fetchOptions.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
            }
            
            let result = PHAsset.fetchAssets(in: obj, options: fetchOptions)
            
            var model: MSTAlbumModel?
            
            if (result.count > 0 || isShowEmpty) {
                model = MSTAlbumModel()
                model?.isCameraRoll = true
                model?.albumName = obj.localizedTitle ?? ""
                model?.content = result
            }
            
            completeClosure(model)
        }
    }
    
    func loadAlbumInfo(isDesc: Bool, isShowEmpty: Bool, isOnlyShowImage: Bool, completeClosure: @escaping ((PHFetchResult<PHCollection>, Array<MSTAlbumModel>) -> Void)) {
        var albumsModelsArray: Array<MSTAlbumModel> = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !isDesc)]
        
        if (isOnlyShowImage) {
            fetchOptions.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
        }
        
        self .loadCameraRollInfo(isDesc: isDesc, isShowEmpty: isShowEmpty, isOnlyShowImage: isOnlyShowImage) { (result) in
            if (result != nil) {
                albumsModelsArray.append(result!)
            }
        }
        
        let albumCollection = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        albumCollection.enumerateObjects { (collection, idx, stop) in
            let assetsResult = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: fetchOptions)
            
            if (assetsResult.count > 0 || isShowEmpty) {
                let model: MSTAlbumModel = MSTAlbumModel()
                model.isCameraRoll = false
                model.albumName = collection.localizedTitle ?? ""
                model.content = assetsResult
                
                albumsModelsArray.append(model)
            }
        }
        
        completeClosure(albumCollection, albumsModelsArray)
    }
    
    func saveImageToSystemAlbum(_ image: UIImage, completeClosure: @escaping ((PHAsset?, String) -> Void)) {
        var createdAssetID: String = ""
        
        PHPhotoLibrary.shared().performChanges({
            createdAssetID = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (success, error) in
            let createAsset: PHAsset? = PHAsset.fetchAssets(withBurstIdentifier: createdAssetID, options: nil).firstObject
            
            completeClosure(createAsset, error?.localizedDescription ?? "")
        }
    }
    
    func saveImageToCustomAlbum(_ image: UIImage, albumName: String, completeClosure: @escaping ((PHAsset?, String) -> Void)) {
        self.saveImageToSystemAlbum(image) { (asset, errStr) in
            if (asset != nil) {
                let collection: PHAssetCollection? = self.p_getAssetCollection(withName: albumName)
                
                guard collection != nil else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    let request: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: collection!)!
                    if asset != nil {
                        request.addAssets([asset!] as NSFastEnumeration)
                    }
                }, completionHandler: { (success, error) in
                    completeClosure(asset, error?.localizedDescription ?? "")
                })
            }
        }
    }
    
    func saveVideoToSystemAlbum(_ url: URL, completeClosure: @escaping ((PHAsset?, String) -> Void)) {
        var createdAssetID: String = ""
        
        PHPhotoLibrary.shared().performChanges({
            createdAssetID = (PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)?.placeholderForCreatedAsset?.localIdentifier)!
        }) { (success, error) in
            let creatAsset: PHAsset? = PHAsset.fetchAssets(withLocalIdentifiers: [createdAssetID], options: nil).firstObject
            
            completeClosure(creatAsset, error?.localizedDescription ?? "")
        }
    }
    
    func saveVideoToCustomAlbum(_ url: URL, albumName: String, completeClosure: @escaping ((PHAsset?, String) -> Void)) {
        saveVideoToSystemAlbum(url) { (asset, error) in
            guard asset != nil else {
                completeClosure(nil, error)
                return
            }
            
            let collection: PHAssetCollection? = self.p_getAssetCollection(withName: albumName)
            
            guard collection != nil else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let request: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: collection!)!
                if asset != nil {
                    request.addAssets([asset!] as NSFastEnumeration)
                }
            }, completionHandler: { (success, error) in
                completeClosure(asset, error?.localizedDescription ?? "")
            })
        }
    }
    
    func sortByMomentType(_ momentType: MSTImageMomentGroupType, assets models: Array<MSTAssetModel>) -> Array<MSTMoment> {
        var newMoment: MSTMoment?
        var groups: Array<MSTMoment> = []
        
        for asset in models {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: asset.asset.creationDate!)
            
            let year: Int = components.year ?? 0
            let month: Int = components.month ?? 0
            let day: Int = components.day ?? 0
            
            switch momentType {
            case .year:
                if newMoment != nil && newMoment?.dateComponents.year == year { break }
            case .month:
                if newMoment != nil && newMoment?.dateComponents.year == year && newMoment?.dateComponents.month == month { break }
            case .day:
                if newMoment != nil && newMoment?.dateComponents.year == year && newMoment?.dateComponents.month == month && newMoment?.dateComponents.day == day { break }
            default:
                newMoment = MSTMoment()
                newMoment?.dateComponents = components
                newMoment?.date = asset.asset.creationDate
                groups.append(newMoment!)
            }
            newMoment?.assets.append(asset)
        }
        return groups
    }
    
    func getMSTAssetModel(identifier: String) -> MSTAssetModel {
        let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject!
        
        return MSTAssetModel.model(asset)
    }
    
    func getMSTAssetModel(fetchResult: PHFetchResult<PHAsset>, completeClosure: @escaping (Array<MSTAssetModel>) -> Void) {
        var modelsArray: Array<MSTAssetModel> = []

        fetchResult.enumerateObjects { (asset, idx, stop) in
            let model: MSTAssetModel = MSTAssetModel.model(asset)
            
            modelsArray.append(model)
            
            if modelsArray.count == fetchResult.count {
                completeClosure(modelsArray)
            }
        }
    }
    
    func thumbnailImage(asset: PHAsset, photoWidth width: CGFloat, completeClosure: @escaping ((UIImage, [AnyHashable : Any]?) -> Void)) {
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isSynchronous = false
        
        p_getImage(asset: asset, imageSize: CGSize(width: width*2, height: width*2), options: options, isFixOrientation: false) { (result, info) in
            completeClosure(result, info)
        }
    }
    
    func previewImage(asset: PHAsset, isHighQuality: Bool, completeClosure: @escaping ((UIImage, [AnyHashable : Any]?, Bool) -> Void)) {
        let scale: CGFloat = isHighQuality ? UIScreen.main.scale : 1
        
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let pixelWidth: CGFloat = kScreenWidth * scale
        let pixelHeight: CGFloat = kScreenWidth / aspectRatio
        let imageSize: CGSize = CGSize(width: pixelWidth, height: pixelHeight)
        
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = isHighQuality ? .highQualityFormat : .fastFormat
        options.isSynchronous = false
        
        p_getImage(asset: asset, imageSize: imageSize, options: options, isFixOrientation: true) { (result, info) in
            completeClosure(result, info, info![PHImageResultIsDegradedKey] as! Bool)
        }
    }
    
    @available(iOS 9.1, *)
    func livePhoto(asset: PHAsset, completeClosure: @escaping ((PHLivePhoto, Bool) -> Void)) {
        let scale: CGFloat = UIScreen.main.scale
        
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let pixelWidth: CGFloat = kScreenWidth * scale
        let pixelHeight: CGFloat = kScreenWidth / aspectRatio
        let imageSize: CGSize = CGSize(width: pixelWidth, height: pixelHeight)
        
        let options: PHLivePhotoRequestOptions = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestLivePhoto(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (livePhoto, info) in
            completeClosure(livePhoto!, info![PHImageResultIsDegradedKey] as! Bool)
        }
    }
    
    func pickingImage(asset: PHAsset, isFullImage: Bool, maxImageWidth width: CGFloat, completeClosure: @escaping ((UIImage, [AnyHashable : Any]?, Bool) -> Void)) {
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        var targetSize: CGSize = CGSize.zero
        
        if isFullImage {
            options.resizeMode = .none
            
            targetSize = PHImageManagerMaximumSize
        } else {
            options.resizeMode = .fast
            
            if width > CGFloat(asset.pixelWidth) {
                targetSize = PHImageManagerMaximumSize
            } else {
                let scale: CGFloat = UIScreen.main.scale
                let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
                let pixelWidth: CGFloat = width * scale
                let pixelHeight: CGFloat = width / aspectRatio
                targetSize = CGSize(width: pixelWidth, height: pixelHeight)
            }
        }
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (result, info) in
            guard result != nil else { return }
            var img: UIImage = result!.mst_fixOrientation()
            
            if !isFullImage {
                img = img.mst_imageByScalingProportionally(maxWidth: width)!
            }
            
            let data: Data = UIImageJPEGRepresentation(img, 0.45)!
            img = UIImage(data: data)!
            
            completeClosure(img, info, info![PHImageResultIsDegradedKey] as! Bool)
        }
    }
    
    func avPlayerItem(asset: PHAsset, completeClosure: @escaping ((AVPlayerItem) -> Void)) {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = false
        options.version = .original
        
        imageManager.requestPlayerItem(forVideo: asset, options: options) { (playerItem, info) in
            completeClosure(playerItem!)
        }
    }
    
    func imageBytes(models: Array<MSTAssetModel>, completeClosure: @escaping ((String) -> Void)) {
        var dataLength: Int64 = 0
        var count: Int = models.count
        
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = .none
        options.isSynchronous = false
        
        for model in models {
            imageManager.requestImageData(for: model.asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                count -= 1
                dataLength += Int64(imageData?.count ?? 0)
                if count <= 0 {
                    completeClosure(ByteCountFormatter.string(fromByteCount: dataLength, countStyle: .file))
                }
            })
        }
    }
    
    private func p_getAssetCollection(withName customName: String) -> PHAssetCollection? {
        let collections: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        var collection: PHCollection?
        collections.enumerateObjects { (tmpCollection, idx, stop) in
            if (tmpCollection.localizedTitle == customName) {
                collection = tmpCollection
            }
        }
        if collection != nil {
            return collection as? PHAssetCollection
        }
        
        var createID: String = ""
        var result: PHAssetCollection?
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request: PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: customName)
                createID = request.placeholderForCreatedAssetCollection.localIdentifier
                
                result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [createID], options: nil).firstObject
            }
        } catch {
            print("Fail to create the custom album")
        }
        
        return result
    }
    
    private func p_getImage(asset: PHAsset, imageSize: CGSize, options: PHImageRequestOptions, isFixOrientation fixOrientation: Bool, completeClosure: (@escaping (_ result: UIImage, _ info: [AnyHashable : Any]?) -> Void)) {
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (result, info) in
            var finished: Bool = true
            if let tmp = info![PHImageCancelledKey] {
                if !(tmp as! Bool) && (info![PHImageErrorKey] != nil) {
                    finished = true
                }
            }
            
            if finished && result != nil {
                let img: UIImage = fixOrientation ? result!.mst_fixOrientation() : result!
                
                completeClosure(img, info)
            }
        }
    }
}



















