//
//  ViewController.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/11.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MSTImagePickerControllerDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var sourceTypePickerView: UIPickerView!
    @IBOutlet weak var isMultiSelected: UISwitch!
    @IBOutlet weak var maxSelectedNum: UITextField!
    @IBOutlet weak var numberOfRow: UITextField!
    @IBOutlet weak var isShowMasking: UISwitch!
    @IBOutlet weak var isShowSelectedAnimation: UISwitch!
    @IBOutlet weak var showThemeType: UISegmentedControl!
    @IBOutlet weak var photoGroupType: UISegmentedControl!
    @IBOutlet weak var isDesc: UISwitch!
    @IBOutlet weak var isShowThumbnail: UISwitch!
    @IBOutlet weak var isShowAlbumNum: UISwitch!
    @IBOutlet weak var isShowEmptyAlbum: UISwitch!
    @IBOutlet weak var isOnlyShowImage: UISwitch!
    @IBOutlet weak var isShowLive: UISwitch!
    @IBOutlet weak var isFirstCamera: UISwitch!
    @IBOutlet weak var allowsMakingVideo: UISwitch!
    @IBOutlet weak var isVideoAutoSave: UISwitch!
    @IBOutlet weak var videoMaximumDuration: UITextField!
    @IBOutlet weak var customAlbumName: UITextField!
    @IBOutlet weak var displayCollectionView: UICollectionView!
    
    // MARK: - Properties
    var sourceType: Int = 1
    var imagePicker: MSTImagePickerController!
    var modelsArray: Array<Any> = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTypePickerView.selectRow(1, inComponent: 0, animated: false)
    }
    
    // MARK: - Instance Methods
    func mp_setupImagePickerController() {
        imagePicker.mstDelegate = self

        imagePicker.config.maxSelectCount = Int(maxSelectedNum.text!)!
        imagePicker.config.numsInRow = Int(numberOfRow.text!)!
        imagePicker.config.isMutiSelected = isMultiSelected.isOn
        imagePicker.config.HasMasking = isShowMasking.isOn
        imagePicker.config.HasSelectAnimation = isShowSelectedAnimation.isOn
        imagePicker.config.themeStyle = MSTImagePickerStyle(rawValue: showThemeType.selectedSegmentIndex)!
        imagePicker.config.photoMomentGroupType = MSTImageMomentGroupType(rawValue:photoGroupType.selectedSegmentIndex)!
        imagePicker.config.isPhotosDesc = isDesc.isOn
        imagePicker.config.hasAlbumThumbnail = isShowThumbnail.isOn
        imagePicker.config.hasPhotosCount = isShowAlbumNum.isOn
        imagePicker.config.hasEmptyAlbum = isShowEmptyAlbum.isOn
        imagePicker.config.isOnlyShowImages = isOnlyShowImage.isOn
        imagePicker.config.hasLivePhotoIcon = isShowLive.isOn
        imagePicker.config.isFirstCamera = isFirstCamera.isOn
        imagePicker.config.hasMakingVideo = allowsMakingVideo.isOn
        imagePicker.config.isVideoAutoSave = isVideoAutoSave.isOn
        imagePicker.config.videoMaxDuration = Double(videoMaximumDuration.text!)!
        imagePicker.config.customAlbumName = customAlbumName.text
    }
    
    // MARK: - Actions
    @IBAction func runButtonDidClicked(_ sender: UIButton) {
        var type: MSTImagePickerAccessType = .photosWithAlbums
        type = MSTImagePickerAccessType(rawValue: sourceType)!
        
        imagePicker = MSTImagePickerController.init(accessType: type)
        mp_setupImagePickerController()

        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        
        switch (row) {
        case 0:
            label.text = "无相册界面，但直接进入相册胶卷"
            break
        case 1:
            label.text = "有相册界面，但直接进入相册胶卷"
            break
        case 2:
            label.text = "直接进入相册界面"
            break
        default:
            label.text = ""
            break
        }
        
        label.sizeThatFits(CGSize(width: self.view.mst_width - 16, height: 20))
        
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sourceType = row
    }
    
    // MARK: - UICollectionViewDataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelsArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath)
        
        return cell;
    }
    
    // MARK: - MSTImagePickerControllerDelegate
    func mstImagePickerControllerAuthiorization(_ pickerController: MSTImagePickerController, sourceType: Int, status: Int) {
        
    }
    
    func mstImagePickerControllerDidCancel(_ pcikerController: MSTImagePickerController) {
        
    }
    
//    func mstImagePickerControllerDidPickedMax(_ pickerContrller: MSTImagePickerController) {
//        print("here")
//    }
}

