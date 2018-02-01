//
//  MSTMoment.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 2017/12/27.
//  Copyright © 2017年 Mustard. All rights reserved.
//

import UIKit

internal class MSTMoment: NSObject {

    var dateComponents: DateComponents!
    
    var date: Date!
    
    var grouptype: MSTImageMomentGroupType = .none
    
    var assets: Array<MSTAssetModel> = []
}
