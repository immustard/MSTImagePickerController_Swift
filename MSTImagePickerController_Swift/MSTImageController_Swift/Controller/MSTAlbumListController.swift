//
//  MSTAlbumListController.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/26.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit
import Photos

internal class MSTAlbumListController: UITableViewController, PHPhotoLibraryChangeObserver {
    // MARK: - Properties
    var collectionResult: PHFetchResult<PHCollection>!
    
    var albumModelsArray: Array<MSTAlbumModel> = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        p_initData()
        p_initView()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self as PHPhotoLibraryChangeObserver)
    }
    
    // MARK: - Instance Methods
    private func p_initView() {
        mst_addNavigationRightCancelButton()
        
        tableView.tableFooterView = UIView()
        
        MSTPhotoManager.checkAuthorizationStatus(sourceType: .photo) { (sourceType, status) in
            DispatchQueue.main.async {
                if status != .authorized {
                    let label: UILabel = UILabel()
                    label.font = UIFont.systemFont(ofSize: 18)
                    label.textColor = UIColor.mst_Color333
                    label.numberOfLines = 0
                    label.textAlignment = .center
                    
                    label.text = MSTTools.localizedString(key: "str_access_photo", value: "请在iPhone的\"设置-隐私-照片\"选项中，\r允许该App访问你的手机相册")
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.view.addSubview(label)
                    self.tableView.isScrollEnabled = false
                    
                    let centerX: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
                    let top: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 100)
                    let width: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: kScreenWidth-30)
                    self.view.addConstraints([centerX, top, width])
                    
                    let btn: UIButton = UIButton(type: .custom)
                    btn.setTitle(MSTTools.localizedString(key: "str_setting", value: "设置"), for: .normal)
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                    btn.addTarget(self, action: #selector(self.p_jumpToSetting), for: .touchUpInside)
                    btn.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.view.addSubview(btn)
                    
                    let centerX1: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
                    let top1: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 20)
                    
                    self.view.addConstraints([centerX1, top1])
                }
            }
        }
    }
    
    private func p_initData() {
        PHPhotoLibrary.shared().register(self as PHPhotoLibraryChangeObserver)
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        MSTPhotoManager.shared().loadAlbumInfo(isDesc: config.isPhotosDesc, isShowEmpty: config.hasEmptyAlbum, isOnlyShowImage: config.isOnlyShowImages) { (customAlbum, albumsArray) in
            self.collectionResult = customAlbum
            self.albumModelsArray = albumsArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    // 跳转到设置
    @objc private func p_jumpToSetting() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    override internal func p_cancelButtonDidClicked() {
        dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name(NCDidCancel), object: nil)
    }

    // MARK: - UITableViewDataSource & Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumModelsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        let model: MSTAlbumModel = albumModelsArray[indexPath.row]
        
        if config.hasAlbumThumbnail {
            let cell: MSTAlbumListCell = MSTAlbumListCell.cellWithTableView(tableView)
            
            cell.albumModel = model
            
            return cell
        } else {
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: kAlbumCellReuseIdentifier)
            
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: kAlbumCellReuseIdentifier)
            }
            
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.text = model.albumName
            
            if config.hasPhotosCount {
                cell!.detailTextLabel?.text = "(\(model.count))"
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        let vc: MSTPhotoGridController = MSTPhotoGridController(collectionViewLayout: MSTPhotoGridController.flowLayoutWithNumInALine(config.numsInRow))
        vc.album = albumModelsArray[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let _ = changeInstance.changeDetails(for: collectionResult) {
            p_initData()
        }
    }
    
}
