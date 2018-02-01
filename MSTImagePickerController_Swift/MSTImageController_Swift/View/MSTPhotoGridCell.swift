//
//  MSTPhotoGridCell.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/27.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit
import PhotosUI

internal let kGridCellReuserIdentifier = "MSTPhotoGridCellID"
internal let kGridCameraCellReuseidentifier = "MSTPhotoGridCameraCellID"

internal protocol MSTPhotoGridCellDelegate {
    func gridCellDidSelectedButtonDidClicked(_ isSelected: Bool, selectedAsset asset: MSTAssetModel) -> Bool
}

// MARK: - MSTPhotoGridCell
internal class MSTPhotoGridCell: UICollectionViewCell {
    // MARK: - Properties
    var asset: MSTAssetModel! {
        didSet {
            MSTPhotoManager.shared().thumbnailImage(asset: asset.asset, photoWidth: self.contentView.mst_width) { (result, info) in
                self.imageView.image = result
            }
            
            let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
            
            videoLengthBgView.isHidden = true
            selectBtn.isHidden = true
            if #available(iOS 9.1, *) {
                liveBadgeImageView.isHidden = true
            }
            if config.HasMasking {
                maskingImgView.isHidden = true
            }
            
            switch asset.type {
            case .video:
                videoLengthBgView.isHidden = false
                videoLengthLabel.text = String(format: "%02d:%02d", Int(asset.videoDuration/60), lroundf(Float(asset.videoDuration.truncatingRemainder(dividingBy: 60))))
            case .livePhoto:
                selectBtn.isHidden = false
                guard config.hasLivePhotoIcon else { break }
                if #available(iOS 9.1, *) {
                    liveBadgeImageView.isHidden = false
                }
            default:
                selectBtn.isHidden = false
            }
            
            selectBtn.isSelected = asset.isSelected
            if asset.isSelected && config.HasMasking {
                maskingImgView.isHidden = false
                p_bringToFront()
            }
        }
    }
    
    var delegate: MSTPhotoGridCellDelegate?
    
    // MARK: - Instance Methods
    private func p_bringToFront() {
        contentView.bringSubview(toFront: selectBtn)
        if #available(iOS 9.1, *) {
            contentView.bringSubview(toFront: liveBadgeImageView)
        }
    }
    
    // MARK: - Actions
    @objc private func p_selectButtonDidClicked(_ sender: UIButton) {
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        var isSelected: Bool = false

        isSelected = (delegate?.gridCellDidSelectedButtonDidClicked(!sender.isSelected, selectedAsset: asset))!
        
        sender.isSelected = isSelected
        if sender.isSelected {
            if #available(iOS 9.0, *) {
                if config.HasSelectAnimation {
                    sender.mst_addSpringAnimation()
                }
            }
            if config.HasMasking {
                maskingImgView.isHidden = false
                p_bringToFront()
            }
        } else {
            if config.HasMasking {
                maskingImgView.isHidden = true
            }
        }
    }
    
    // MARK: - Lazy Load
    private lazy var imageView: UIImageView = {
        let imgView: UIImageView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(imgView)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([top, leading, trailing, bottom])
        
        return imgView
    }()
    
    private lazy var videoLengthBgView: UIImageView = {
        let imgView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "icon_grid_videoLength"))
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(imgView)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -24)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([top, leading, trailing, bottom])
        
        return imgView
    }()
    
    private lazy var videoLengthLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.videoLengthBgView.addSubview(label)
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self.videoLengthBgView, attribute: .trailing, multiplier: 1, constant: -3)
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.videoLengthBgView, attribute: .centerY, multiplier: 1, constant: 3)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self.videoBadgeImageView, attribute: .leading, multiplier: 1, constant: 0)
        
        self.videoLengthBgView.addConstraints([leading, centerY, trailing])
        
        return label
    }()
    
    private lazy var videoBadgeImageView: UIImageView = {
        let imgView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "icon_grid_video_badge"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.videoLengthBgView.addSubview(imgView)
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.videoLengthBgView, attribute: .leading, multiplier: 1, constant: 3)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
        let width: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self.videoLengthBgView, attribute: .centerY, multiplier: 1, constant: 3)
        
        self.videoLengthBgView.addConstraints([leading, height, centerY, width])
        
        return imgView
    }()
    
    @available(iOS 9.1, *)
    private lazy var liveBadgeImageView: UIImageView = {
        let imgView: UIImageView = UIImageView(image: PHLivePhotoView.livePhotoBadgeImage(options: .overContent))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(imgView)
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let width: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 30)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 30)
        
        self.contentView.addConstraints([leading, top, width, height])
        
        return imgView
    }()
    
    private lazy var selectBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        
        btn.setImage(config.photoPickNormalImage ?? #imageLiteral(resourceName: "icon_picture_normal"), for: .normal)
        btn.setImage(config.photoPickSelectedImage ?? #imageLiteral(resourceName: "icon_picture_selected"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        btn.addTarget(self, action: #selector(p_selectButtonDidClicked(_:)), for: .touchUpInside)
        
        self.contentView.addSubview(btn)
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let top: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let width: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -self.frame.size.width/3)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: btn, attribute: .height, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([trailing, top, width, height])
        
        return btn
    }()
    
    private lazy var maskingImgView: UIImageView = {
        let imgView: UIImageView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imgView)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([top, leading, bottom, trailing])
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        
        switch config.themeStyle {
        case .dark:
            imgView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        case .light:
            imgView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        }
        
        return imgView
    }()
}

// MARK: - MSTPhotoGridCameraCell
internal class MSTPhotoGridCameraCell: UICollectionViewCell {
    // MARK: - Properties
    var cameraImage: UIImage? {
        didSet {
            self.imageView.image = cameraImage
        }
    }
    
    // MARK: - Lazy Load
    private lazy var imageView: UIImageView = {
        let imgView: UIImageView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(imgView)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([top, leading, trailing, bottom])
        
        return imgView
    }()
    
    private lazy var cameraView: MSTCameraView = {
        let view: MSTCameraView = MSTCameraView.init(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()

        view.setPreviewLayerFrame(CGRect(x: 0, y: 0, width: config.gridWidth, height: config.gridWidth))
        
        self.contentView.addSubview(view)
        
        let top: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.contentView.addConstraints([top, leading, trailing, bottom])
        
        return view
    }()
    
    // MARK: - Instance Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = #imageLiteral(resourceName: "icon_album_camera")
        if MSTPhotoConfiguration.shared().isDynamicCamera {
            cameraView.startSession()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
