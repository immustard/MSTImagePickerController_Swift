//
//  UIViewControllerMST.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/27.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

internal extension UIViewController {
    func mst_addNavigationRightCancelButton() {
        let item: UIBarButtonItem = UIBarButtonItem(title: MSTTools.localizedString(key: "str_cancel", value: "取消"), style: .plain, target: self, action: #selector(p_cancelButtonDidClicked))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc internal func p_cancelButtonDidClicked() {
        
    }
    
    func mst_addAlertController(title: String, actionTitle: String) -> UIAlertController {
        let ctrler: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let action: UIAlertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        ctrler.addAction(action)
        
        return ctrler
    }
}
