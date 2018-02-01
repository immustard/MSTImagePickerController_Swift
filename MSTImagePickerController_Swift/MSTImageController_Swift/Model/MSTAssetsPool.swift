//
//  MSTAssetsPool.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 28/12/2017.
//  Copyright © 2017 Mustard. All rights reserved.
//

import Photos

class MSTAssetsPool: NSObject {
    public class func shared() -> MSTAssetsPool {
        struct Static {
            static let instance = MSTAssetsPool()
        }
        return Static.instance
    }
    
    // MARK: - Properties
    private var pickedModels: Array<MSTAssetModel> = []
    private var pickedModelIdentifiers: Array<String> = []
    
    // MARK: - Instance Methods
    /// 添加选中
    ///
    /// - Parameter asset: 选中的 asset
    /// - Returns: 是否添加成功
    func addSelectedAsset(_ asset: MSTAssetModel) -> Bool {
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()

        if pickedModelIdentifiers.count == config.maxSelectCount {
            NotificationCenter.default.post(name: Notification.Name(NCDidSelectedMaxCount), object: nil)
            
            return false
        }
        
        if containAssetModel(asset) { return true }
        
        asset.isSelected = true
        pickedModels.append(asset)
        pickedModelIdentifiers.append(asset.identifier)
        
        NotificationCenter.default.post(name: Notification.Name(NCRefreshToolBar), object: nil)
        
        return true
    }
    
    /// 移除选中
    ///
    /// - Parameter asset: 选中的 asset
    /// - Returns: 是否移除成功
    func removeSelectedAsset(_ asset: MSTAssetModel) -> Bool {
        if containAssetModel(asset) {
            asset.isSelected = false
            
            let idx: Int = pickedModelIdentifiers.index(of: asset.identifier)!
            
            pickedModelIdentifiers.remove(at: idx)
            pickedModels.remove(at: idx)
            
            NotificationCenter.default.post(name: Notification.Name(NCRefreshToolBar), object: nil)

            return true
        }
        return false
    }
    
    /// 清除全部
    func clean() {
        pickedModels.removeAll()
        pickedModelIdentifiers.removeAll()
    }
    
    /// 已经选中的 asset 的数量
    func hasSelectedModelCount() -> Int {
        return pickedModels.count
    }
    
    /// 已经选中的 identifier 的数量
    func hasSelectedIdentifierCount() -> Int {
        return pickedModelIdentifiers.count
    }
    
    /// 获取已经选中的 asset
    func getPickedAssets() -> Array<MSTAssetModel> {
        return pickedModels
    }
    
    /// 选中图片中是否包含该 model
    ///
    /// - Parameter asset: 需判断的 asset
    /// - Returns: 是否选中
    func containAssetModel(_ asset: MSTAssetModel) -> Bool {
        return pickedModelIdentifiers.contains(asset.identifier)
    }

}











