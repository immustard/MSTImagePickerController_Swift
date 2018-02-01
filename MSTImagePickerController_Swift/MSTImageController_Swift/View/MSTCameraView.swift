//
//  MSTCameraView.swift
//  MSTImagePickerController_Swift
//
//  Created by 张宇豪 on 03/01/2018.
//  Copyright © 2018 Mustard. All rights reserved.
//

import UIKit
import AVFoundation

class MSTCameraView: UIView {

    // MARK: - Properties
    /// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
    private let session: AVCaptureSession = AVCaptureSession()
    
    /// 输入设备
    private var videoInput: AVCaptureDeviceInput!
    
    /// 照片输出流
    private var stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
    /// 预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    // MARK: - Instance Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        p_initAVCaptureSession()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPreviewLayerFrame(_ frame: CGRect) {
        previewLayer.frame = frame
    }
    
    func startSession() {
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }

    private func p_initAVCaptureSession() {
        let device: AVCaptureDevice = AVCaptureDevice.default(for: .video)!
        
        // 更改这个设置的时候必须先锁定设备
        do {
            try device.lockForConfiguration()
        } catch {
            print("锁定设备失败, 初始化AVCapture失败")
        }
        
        // 设置闪光灯为自动
        device.flashMode = .auto
        device.unlockForConfiguration()
        
        do {
            try videoInput = AVCaptureDeviceInput.init(device: device)
        } catch {
            print("初始化输入设备失败")
        }
        
        // 输出设置
        let setting: [String: String] = [AVVideoCodecKey: AVVideoCodecJPEG]
        stillImageOutput.outputSettings = setting
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
        
        // 初始化预览图层
        layer.masksToBounds = true
        layer.addSublayer(previewLayer)
    }
}
