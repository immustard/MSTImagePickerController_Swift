//
//  MSTPhotoGridController.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/26.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

internal class MSTPhotoGridController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MSTPhotoGridCellDelegate {
    // MARK: - Properties
    // 相册信息
    var album: MSTAlbumModel! {
        didSet {
            self.title = album.albumName
        
            self.isMoment = (config.photoMomentGroupType != .none)
            
            // TODO: - Waiting for updating. 当显示相机并且根据时间分组的情况下, 把相机放在当前时间组, 没有则创建
            self.isShowCamera = (config.isFirstCamera && album.isCameraRoll)
        }
    }
    
    private var config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
    
    private var isFirstAppear: Bool = false
    
    private var isShowCamera: Bool = false
    
    private var isMoment: Bool = false
    
    private var momentsArray: Array<MSTMoment> = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        isFirstAppear = true
        p_initData()
        p_initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !config.isPhotosDesc && isFirstAppear {
            p_scrollToBottom()
            isFirstAppear = false
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Class Methods
    /// 添加 flowLayout
    ///
    /// - Parameter num: 一行有几个cell
    /// - Returns: flowLayout
    class func flowLayoutWithNumInALine(_ num: Int) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()

        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: config.gridWidth, height: config.gridWidth)
        flowLayout.minimumLineSpacing = config.gridPadding
        flowLayout.sectionInset = UIEdgeInsets(top: config.gridPadding, left: config.gridPadding, bottom: config.gridPadding, right: config.gridPadding)
        
        return flowLayout
    }

    // MARK: - Instance Methods
    private func p_initData() {
        PHPhotoLibrary.shared().register(self)
        
        // TODO: - Waiting for testing. 在大量图片的情况下, 测试选中状态
        DispatchQueue(label: "grid_init_data").async {
            self.p_checkSelectedStatus()
        }
    }
    
    private func p_initView() {
        mst_addNavigationRightCancelButton()
        
        view.backgroundColor = UIColor.white
        collectionView?.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        collectionView?.mst_top = kNavHeight
        collectionView?.mst_height = view.mst_height - kNavHeight - kToolBarHeight
        
        collectionView?.register(MSTPhotoGridCell.classForCoder(), forCellWithReuseIdentifier: kGridCellReuserIdentifier)
        collectionView?.register(MSTPhotoGridHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kGridHeaderReuseidentifier)
        if isShowCamera {
            collectionView?.register(MSTPhotoGridCameraCell.classForCoder(), forCellWithReuseIdentifier: kGridCameraCellReuseidentifier)
        }
    }
    
    // 判断是否选中
    private func p_checkSelectedStatus() {
        let pool: MSTAssetsPool = MSTAssetsPool.shared()
        for model in album.models {
            model.isSelected = pool.containAssetModel(model)
        }
    }
    
    private func p_refreshMoments() {
        momentsArray.removeAll()
        momentsArray = MSTPhotoManager.shared().sortByMomentType(config.photoMomentGroupType, assets: album.models)
    }
    
    private func p_addCameraCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> MSTPhotoGridCameraCell {
        let cell: MSTPhotoGridCameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: kGridCameraCellReuseidentifier, for: indexPath) as! MSTPhotoGridCameraCell
        if config.cameraImage != nil {
            cell.cameraImage = config.cameraImage
        }
        
        return cell
    }
    
    // MARK: - Actions
    private func p_scrollToBottom() {
        var item: Int = 0
        var section: Int = 0
        
        if isMoment {
            if let moment: MSTMoment = momentsArray.last {
                item = moment.assets.count - 1
                section = momentsArray.count - 1
            } else {
                item = album.count - 1
                section = 0
            }
        }
        
        if isShowCamera {
            item += 1
        }
        
        collectionView?.scrollToItem(at: IndexPath(item: item, section: section), at: .bottom, animated: false)
    }
    
    override func p_cancelButtonDidClicked() {
        dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name(NCDidCancel), object: nil)
    }
    
    private func p_jumpToUIImagePickerController() {
        // TODO: - 自定义相机界面
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerCtrler: UIImagePickerController = UIImagePickerController()
            pickerCtrler.sourceType = .camera
            pickerCtrler.delegate = self
            
            if config.hasMakingVideo && MSTAssetsPool.shared().hasSelectedIdentifierCount() == 0 {
                pickerCtrler.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
                pickerCtrler.videoMaximumDuration = config.videoMaxDuration
            }
            
            present(pickerCtrler, animated: true, completion: nil)
        }
    }

    // MARK: - UICollectionViewDataSource & Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isMoment {
            return momentsArray.count
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isMoment {
            // 按时间分组的情况
            let moment: MSTMoment = momentsArray[section]
            if isShowCamera && ((config.isPhotosDesc && section != 0) || (!config.isPhotosDesc && section == momentsArray.count-1)) {
                // 有相机, 并且正序第一或倒序最后一段
                return moment.assets.count+1
            } else {
                return moment.assets.count
            }
        } else {
            if isShowCamera {
                return album.count+1
            } else {
                return album.count
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var model: MSTAssetModel!
        
        // 判断显示相机, 如果显示相机, 里面的代码...说真的. 我现在都不太理解, 如果要看的话...尽量看吧.
        if isShowCamera {
            if config.isPhotosDesc {
                if isMoment {
                    // 根据时间分组
                    let moment: MSTMoment = momentsArray[indexPath.section]
                    
                    if indexPath.item == 0 && indexPath.section == 0 {
                        // 第一段第一个
                        return p_addCameraCell(collectionView, indexPath: indexPath)
                    } else {
                        if indexPath.section == 0 {
                            // 第一段
                            model = moment.assets[indexPath.item-1]
                        } else {
                            model = moment.assets[indexPath.item]
                        }
                    }
                } else {
                    // 未根据时间分组
                    if indexPath.item == 0 {
                        // 第一个
                        return p_addCameraCell(collectionView, indexPath: indexPath)
                    } else {
                        model = album.models[indexPath.item-1]
                    }
                }
            } else {
                if isMoment {
                    let moment: MSTMoment = momentsArray[indexPath.section]
                    
                    if indexPath.section == momentsArray.count-1 && indexPath.item >= moment.assets.count {
                        return p_addCameraCell(collectionView, indexPath: indexPath)
                    } else {
                        model = moment.assets[indexPath.item]
                    }
                } else {
                    if indexPath.item >= album.count {
                        return p_addCameraCell(collectionView, indexPath: indexPath)
                    } else {
                        model = album.models[indexPath.item]
                    }
                }
            }
        } else {
            if isMoment {
                let moment: MSTMoment = momentsArray[indexPath.section]
                model = moment.assets[indexPath.item]
            } else {
                model = album.models[indexPath.item]
            }
        }
        
        let cell: MSTPhotoGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: kGridCellReuserIdentifier, for: indexPath) as! MSTPhotoGridCell
        cell.delegate = self
        cell.asset = model

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        var item: Int = 0
        var pushToCamera = false
        
        if isShowCamera {
            if config.isPhotosDesc {
                if isMoment {
                    //根据时间分组
                    if indexPath.item == 0 && indexPath.section == 0 {
                        //第一段第一个
                        pushToCamera = true;
                    } else {
                        if indexPath.section == 0 {
                            //第一段
                            item = indexPath.item-1;
                        } else {
                            for i in 0..<indexPath.section {
                                let moment: MSTMoment = momentsArray[i]
                                item += moment.assets.count
                            }
                            item += indexPath.item;
                        }
                    }
                } else {
                    //未根据之间分组
                    if indexPath.item == 0 {
                        //第一个
                        pushToCamera = true
                    } else {
                        item = indexPath.item-1
                    }
                }
            } else {
                if isMoment {
                    let moment: MSTMoment = momentsArray[indexPath.section]
                    
                    if indexPath.section == momentsArray.count - 1 && indexPath.item >= moment.assets.count {
                        pushToCamera = true
                    } else {
                        for i in 0..<indexPath.section {
                            let moment: MSTMoment = momentsArray[i]
                            item += moment.assets.count
                        }
                        item += indexPath.item;
                    }
                } else {
                    if indexPath.item >= album.count {
                        pushToCamera = true
                    } else {
                        item = indexPath.item;
                    }
                }
            }
        } else {
            if isMoment {
                for i in 0..<indexPath.section {
                    let moment: MSTMoment = momentsArray[i]
                    item += moment.assets.count
                }
                item += indexPath.item;
            } else {
                item = indexPath.item;
            }
        }
        
        if pushToCamera {
            p_jumpToUIImagePickerController()
        } else {
            let model = album.models[item]
            
            if model.type == .video {
                
            } else {
                
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard isMoment else { return CGSize.zero }
        
        return CGSize(width: kScreenWidth, height: 44)
    }
    
    // MARK: - MSTPhotoGridCellDelegate
    func gridCellDidSelectedButtonDidClicked(_ isSelected: Bool, selectedAsset asset: MSTAssetModel) -> Bool {
        let pool: MSTAssetsPool = MSTAssetsPool.shared()
        
        if isSelected {
            return pool.addSelectedAsset(asset)
        } else {
            _ = pool.removeSelectedAsset(asset)
            return false
        }
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
