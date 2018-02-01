//
//  MSTAlbumListCell.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/26.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit
import Photos

internal let kAlbumCellReuseIdentifier = "MSTAlbumListCellID"

internal class MSTAlbumListCell: UITableViewCell {

    // MARK: - Properties
    var albumModel: MSTAlbumModel! {
        didSet {
            p_initInfo()
        }
    }
    
    private var frontImageView: UIImageView!
    private var middleImageView: UIImageView!
    private var behindImageView: UIImageView!
    
    // MARK: - Class Methods
    class func cellWithTableView(_ tableView: UITableView) -> MSTAlbumListCell {
        var cell: MSTAlbumListCell? = tableView.dequeueReusableCell(withIdentifier: kAlbumCellReuseIdentifier) as? MSTAlbumListCell
        
        if cell == nil {
            cell = MSTAlbumListCell(style: .value1, reuseIdentifier: kAlbumCellReuseIdentifier)
            cell!.p_initView()
        }
        
        return cell!
    }
    
    // MARK: - Instance Methods
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func p_initView() {
        accessoryType = .disclosureIndicator
        
        behindImageView = UIImageView()
        behindImageView.contentMode = .scaleAspectFill
        behindImageView.clipsToBounds = true
        behindImageView.tag = 2
        self.contentView.addSubview(behindImageView)
        self.contentView.addConstraints(self.p_addLayoutContraints(behindImageView))
        
        middleImageView = UIImageView()
        middleImageView.contentMode = .scaleAspectFill
        middleImageView.clipsToBounds = true
        middleImageView.tag = 1
        self.contentView.addSubview(middleImageView)
        self.contentView.addConstraints(self.p_addLayoutContraints(middleImageView))
        
        frontImageView = UIImageView()
        frontImageView.contentMode = .scaleAspectFill
        frontImageView.clipsToBounds = true
        frontImageView.tag = 0
        self.contentView.addSubview(frontImageView)
        self.contentView.addConstraints(self.p_addLayoutContraints(frontImageView))
    }
    
    private func p_initInfo() {
        let config: MSTPhotoConfiguration = MSTPhotoConfiguration.shared()
        
        // 相册名
        textLabel?.text = albumModel.albumName
        
        // 照片个数
        if config.hasPhotosCount {
            detailTextLabel?.text = "(\(albumModel.count))"
        }
        
        // 缩略图
        frontImageView.image = nil
        middleImageView.image = nil
        behindImageView.image = nil
        imageView?.image = nil
        
        if config.hasAlbumThumbnail {
            let itemSize: CGSize = CGSize(width: 50, height: 65)
            
            UIGraphicsBeginImageContext(itemSize)
            let imageRect: CGRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
            self.imageView?.image?.draw(in: imageRect)
            imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if albumModel.count > 0 {
                // 读取缩略图
                var fetchImageIdx: Int = config.isPhotosDesc ? 0 : albumModel.count-1
                
                var thumbnails: Array<UIImage> = []
                
                let count = min(albumModel.count, 3)
                for i in 0..<count {
                    PHCachingImageManager.default().requestImage(for: albumModel.content[fetchImageIdx], targetSize: CGSize(width: 80*2, height: 80*2), contentMode: .aspectFit, options: nil, resultHandler: { (result, info) in
                        if result != nil {
                            thumbnails.append(result!)
                        }
                        
                        if i == count-1 {
                            DispatchQueue.main.async {
                                for j in 0..<count {
                                    switch j {
                                    case 0:
                                        if (thumbnails.count != 0) {
                                            self.frontImageView.image = thumbnails[j]
                                        }
                                    case 1:
                                        if (thumbnails.count > 1) {
                                            self.middleImageView.image = thumbnails[j]
                                        }
                                    case 2:
                                        if (thumbnails.count > 2) {
                                            self.behindImageView.image = thumbnails[j]
                                        }
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                    })
                    if config.isPhotosDesc {
                        fetchImageIdx += 1
                    } else {
                        fetchImageIdx -= 1
                    }
                }
            } else {
                if config.placeholderThumbnail != nil {
                    self.frontImageView.image = config.placeholderThumbnail
                } else {
                    self.frontImageView.image = #imageLiteral(resourceName: "icon_album_placeholder")
                }
            }
        }
    }
    
    private func p_addLayoutContraints(_ imageView: UIImageView) -> Array<NSLayoutConstraint> {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tag: Int = imageView.tag
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: CGFloat(7+tag*2))
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -CGFloat(7+tag*6))
        let top: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: CGFloat(17-tag*2))
        let width: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: 0)
        
        return [leading, bottom, top, width]
    }
}
