//
//  CameraView.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate {
    func determineMaxThumbnails() -> Int
    func createPreviewLayer() -> (CGRect?, AVCaptureVideoPreviewLayer?)
}

class CameraView: UIView {

    var delegate:CameraViewControllerDelegate?
    
    var thumbNails = [UIImageView]()
    var thumbNailGallery = UIView()
    var cameraPreview = UIView()
    var maxThumbnails:Int!
    var initialPosition:CGPoint?
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupThumbnailView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPreviewLayer(){
        let tuple = (delegate?.createPreviewLayer())!
        let bounds = tuple.0
        previewLayer = tuple.1
        previewLayer.bounds = bounds!
        previewLayer.position = CGPointMake(bounds!.midX, bounds!.midY)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, bounds!.size.width, bounds!.size.height))
        cameraPreview.layer.addSublayer(previewLayer)
        insertSubview(cameraPreview, belowSubview: thumbNailGallery)
    }
    
    override func layoutSubviews() {
        thumbNailGallery.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        thumbNailGallery.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        thumbNailGallery.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -10).active = true
        thumbNailGallery.heightAnchor.constraintEqualToConstant(100).active = true
    }
    
    func setupThumbnailView(){
        thumbNailGallery.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbNailGallery)
        maxThumbnails = delegate?.determineMaxThumbnails()
    }
    
    func useTestLabels() {
        let angleLabel:UILabel = UILabel()
        addSubview(angleLabel)
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        angleLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        angleLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        angleLabel.intrinsicContentSize()
        angleLabel.text = "angelLabel"
        angleLabel.backgroundColor = UIColor.lightGrayColor()
        
        let magnitudeLabel:UILabel = UILabel()
        addSubview(magnitudeLabel)
        magnitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        magnitudeLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        magnitudeLabel.topAnchor.constraintEqualToAnchor(angleLabel.bottomAnchor, constant: 10).active = true
        magnitudeLabel.intrinsicContentSize()
        magnitudeLabel.text = "attitudeLabel"
        magnitudeLabel.backgroundColor = UIColor.lightGrayColor()
    }

}
