//
//  UIColorMST.swift
//  MSTTools_Swift
//
//  Created by 张宇豪 on 2017/6/15.
//  Copyright © 2017年 张宇豪. All rights reserved.
//

import UIKit

internal extension UIColor {
    static let mst_Color333: UIColor = mst_RGBColor(r: 0x33, g: 0x33, b: 0x33)
    static let mst_Color666: UIColor = mst_RGBColor(r: 0x66, g: 0x66, b: 0x66)
    static let mst_Color999: UIColor = mst_RGBColor(r: 0x99, g: 0x99, b: 0x99)
    static let mst_ColorCCC: UIColor = mst_RGBColor(r: 0xCC, g: 0xCC, b: 0xCC)
    
    static var mst_RandomColor: UIColor {
        return mst_RGBColor(r: CGFloat(arc4random()%256)/255, g: CGFloat(arc4random()%256)/255, b: CGFloat(arc4random()%256)/255)
    }
    
    class func mst_RGBColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return mst_RGBAColor(r: r, g: g, b: b, a: 1)
    }
    
    class func mst_RGBAColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
