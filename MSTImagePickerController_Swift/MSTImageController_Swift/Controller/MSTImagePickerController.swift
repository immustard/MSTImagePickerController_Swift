//
//  MSTImagePickerController.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/11.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

protocol MSTImagePickerControllerProtocol {
    
}

@objc protocol MSTImagePickerControllerDelegate {
    /// 授权状态
    ///
    /// - Parameters:
    ///   - pickerController: MSTImagepickerController
    ///   - sourceType: 0: 照片, 1: 相机, 2: 麦克风
    ///   - status: 0: 未知, 1: 受限制, 2: 拒绝, 3: 授权
    @objc optional func mstImagePickerControllerAuthiorization(_ pickerController: MSTImagePickerController, sourceType: Int, status: Int)
    
    /// 取消选择
    ///
    /// - Parameter pcikerController: MSTImagepickerController
    @objc optional func mstImagePickerControllerDidCancel(_ pickerController: MSTImagePickerController)
    
    /// 已经选择到最大, 如果实现这个方法, 则不弹出 Alert
    ///
    /// - Parameter pickerContrller: MSTImagepickerController
    @objc optional func mstImagePickerControllerDidPickedMax(_ pickerContrller: MSTImagePickerController)
}

public class MSTImagePickerController: UINavigationController, MSTImagePickerControllerProtocol {
    
    // MARK: - Properties
    let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
    
    var mstDelegate: MSTImagePickerControllerDelegate?
    
    private var accessType: MSTImagePickerAccessType = .photosWithAlbums
    
    private var toolbarEnable: Bool = false
    
    // MARK: - Lazy Load
    private lazy var albumListController: MSTAlbumListController = {
        let vc = MSTAlbumListController()
        
        return vc
    }()
    
    private lazy var photoGridController: MSTPhotoGridController = {
        let vc = MSTPhotoGridController(collectionViewLayout: MSTPhotoGridController.flowLayoutWithNumInALine(self.config.numsInRow))
        MSTPhotoManager.shared().loadCameraRollInfo(isDesc: config.isPhotosDesc, isShowEmpty: config.hasEmptyAlbum, isOnlyShowImage: config.isOnlyShowImages, completeClosure: { (album) in
            if album != nil {
                vc.album = album
            }
        })
        return vc
    }()
    
    private lazy var previewBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        let str: String = MSTTools.localizedString(key: "str_preview", value: "预览")
        
        btn.frame = CGRect(x: 0, y: 0, width: str.mst_textWidth(maxHeight: 22, font: UIFont.systemFont(ofSize: 17))+20, height: kToolBarHeight)
        btn.setTitleColor(UIColor.mst_Color333, for: .normal)
        btn.setTitleColor(UIColor.mst_Color999, for: .disabled)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.setTitle(str, for: .normal)
        
        btn.addTarget(self, action: #selector(p_previewButtonDidClicked(_:)), for: .touchUpInside)
        
        toolbar.addSubview(btn)
        
        return btn
    }()
    
    private lazy var originalImageBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        
        btn.frame = CGRect(x: previewBtn.mst_right, y: 5, width: kToolBarHeight-10, height: kToolBarHeight-10)
        btn.setImage(#imageLiteral(resourceName: "icon_full_image_normal"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "icon_full_image_selected").mst_toNewByColor(config.themeColor), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        btn.addTarget(self, action: #selector(p_originalButtonDidClicked(_:)), for: .touchUpInside)
        
        toolbar.addSubview(btn)
        
        return btn
    }()
    
    private lazy var originalTextBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        let str: String = MSTTools.localizedString(key: "str_original", value: "原图")
        
        btn.frame = CGRect(x: originalImageBtn.mst_right, y: 0, width: str.mst_textWidth(maxHeight: 20, font: UIFont.systemFont(ofSize: 15))+5, height: kToolBarHeight)
        btn.setTitle(str, for: .normal)
        btn.setTitleColor(UIColor.mst_Color333, for: .normal)
        btn.setTitleColor(UIColor.mst_Color999, for: .selected)
        btn.setTitleColor(UIColor.mst_Color999, for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        btn.addTarget(self, action: #selector(p_originalButtonDidClicked(_:)), for: .touchUpInside)
        
        toolbar.addSubview(btn)
        
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        let str: String = MSTTools.localizedString(key: "str_done", value: "完成")
        
        btn.frame = CGRect(x: toolbar.mst_width-str.mst_textWidth(maxHeight: 20, font: UIFont.systemFont(ofSize: 17))-20, y: 0, width: str.mst_textWidth(maxHeight: 20, font: UIFont.systemFont(ofSize: 17)), height: kToolBarHeight)
        btn.setTitle(str, for: .normal)
        btn.setTitleColor(config.themeColor, for: .normal)
        btn.setTitleColor(config.themeLightColor, for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        btn.addTarget(self, action: #selector(p_doneButtonDidClicked(_:)), for: .touchUpInside)
        
        toolbar.addSubview(btn)
        
        return btn
    }()
    
    private lazy var pickedCountLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: doneBtn.mst_left - 31, y: (kToolBarHeight-28)/2, width: 28, height: 28))
        
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.backgroundColor = config.themeColor
        label.textAlignment = .center
        label.mst_cornerRadius(radius: 14)
        
        toolbar.addSubview(label)
        
        return label
    }()
    
    private lazy var originalSizeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: originalTextBtn.mst_right, y: 0, width: 80, height: kToolBarHeight))
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.mst_Color333
        
        toolbar.addSubview(label)
        
        return label
    }()
    
    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        p_initNavigationBar()
        p_initToolBar()
        p_bindingNotifications()
    }
    
    // MARK: - Initialization Methods
    convenience init (accessType: MSTImagePickerAccessType) {
        self.init()
        MSTPhotoConfiguration.shared().isLocalizedString = false

        MSTAssetsPool.shared().clean()

        self.accessType = accessType
        self.albumListController.title = MSTTools.localizedString(key: "str_photos", value: "相册")
        self.p_checkAuthorizationStatus()
    }
    
//    convenience init (accessType: MSTImagePickerAccessType, identifiers: Array<String>) {
//        self.init(accessType: accessType)
//    }
    
    // MARK: - Instance Methods
    /// 是否选中的是原图
    func isFullImage() -> Bool {
        return false
    }
    
    /// 设置是否是原图
    func setFullImageOption(_ isFullImage: Bool) {
        
    }
    
    // 检查授权状态
    private func p_checkAuthorizationStatus() {
        MSTPhotoManager.checkAuthorizationStatus(sourceType: .photo) { (source, status) in
            DispatchQueue.main.async {
                self.mstDelegate?.mstImagePickerControllerAuthiorization?(self, sourceType: source.rawValue, status: status.rawValue)
                
                if status == .authorized {
                    self.setToolbarHidden(false, animated: false)
                    
                    switch self.accessType {
                    case .albums:
                        self.setViewControllers([self.albumListController], animated: false)
                    case .photosWithAlbums:
                        self.setViewControllers([self.albumListController, self.photoGridController], animated: false)
                    case .photosWithoutAlbums:
                        self.setViewControllers([self.photoGridController], animated: false)
                    }
                } else {
                    self.setViewControllers([self.albumListController], animated: true)
                }
            }
        }
    }
    
    // 初始化导航栏
    private func p_initNavigationBar() {
        switch self.config.themeStyle {
        case .light:
            self.navigationBar.barStyle = .default
            self.navigationBar.isTranslucent = true
        case .dark:
            self.navigationBar.barStyle = .black
            self.navigationBar.isTranslucent = true
            self.navigationBar.tintColor = UIColor.white
        }
    }
    
    private func p_initToolBar() {
        self.toolbar.layoutIfNeeded()
        
        p_setToolBarButtonsEnabled()
        originalSizeLabel.text = ""
    }
    
    private func p_bindingNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(p_cancelAction), name: Notification.Name(NCDidCancel), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(p_didPickMaxAction), name: Notification.Name(NCDidSelectedMaxCount), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(p_setToolBarButtonsEnabled), name: Notification.Name(NCRefreshToolBar), object: nil)
    }
    
    private func p_refreshOriginalText() {
        if originalImageBtn.isSelected {
            let pool: MSTAssetsPool = MSTAssetsPool.shared()
            
            MSTPhotoManager.shared().imageBytes(models: pool.getPickedAssets(), completeClosure: { (result) in
                self.originalSizeLabel.text = "(\(result))"
            })
        } else {
            originalSizeLabel.text = nil
        }
    }
    
    // MARK: - Actions
    @objc private func p_setToolBarButtonsEnabled() {
        let pool: MSTAssetsPool = MSTAssetsPool.shared()
        let pickedCount: Int = pool.hasSelectedIdentifierCount()
        toolbarEnable = pickedCount != 0

        previewBtn.isEnabled = toolbarEnable
        originalImageBtn.isEnabled = toolbarEnable
        originalTextBtn.isEnabled = toolbarEnable
        doneBtn.isEnabled = toolbarEnable
        pickedCountLabel.isHidden = !toolbarEnable
        pickedCountLabel.text = "\(MSTAssetsPool.shared().hasSelectedIdentifierCount())"
        
        if pickedCount == 0 {
            originalImageBtn.isSelected = false
            originalTextBtn.isSelected = false
        }
        
        self.originalImageBtn.isHidden = !config.isAllowOriginImage
        self.originalTextBtn.isHidden = !config.isAllowOriginImage
        
        // TODO: - 等待预览功能
        //        previewBtn.isHidden = true
        
        // 刷新用
        if toolbarEnable {
            pickedCountLabel.text = "\(pickedCount)"
            if #available(iOS 9.0, *) {
                if config.HasSelectAnimation {
                    pickedCountLabel.mst_addSpringAnimation()
                }
            }
            
            p_refreshOriginalText()
        }
    }
    
    @objc private func p_previewButtonDidClicked(_ sender: UIButton) {
        
    }
    
    @objc private func p_originalButtonDidClicked(_ sender: UIButton) {
        let selected: Bool = !sender.isSelected
        originalImageBtn.isSelected = selected
        originalTextBtn.isSelected = selected
        
        p_refreshOriginalText()
    }
    
    @objc private func p_doneButtonDidClicked(_ sender: UIButton) {
        
        if config.isAutoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func p_cancelAction() {
        mstDelegate?.mstImagePickerControllerDidCancel?(self)
        MSTAssetsPool.shared().clean()

        if config.isAutoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func p_didPickMaxAction() {
        guard let _ = mstDelegate?.mstImagePickerControllerDidPickedMax?(self) else {
            let ctrler: UIAlertController = UIAlertController(title: "最多选择\(config.maxSelectCount)张图片", message: nil, preferredStyle: .alert)
            
            let confirm: UIAlertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            ctrler.addAction(confirm)
            present(ctrler, animated: true, completion: nil)
            
            return;
        }
    }
}







