//
//  CameraViewController.swift
//  flickSnap
//
//  Created by Stanley Chiang on 6/30/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class CameraViewController: UIViewController, CameraViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    var cameraview: CameraView!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice!
    var error: NSError?

    var thumbNails = [UIImage]()
    
    let motionManager = CMMotionManager()
    var vibrated = false
    var faceDetected:Bool = true

    override func loadView() {
        super.loadView()
        let cameraview = CameraView()
        cameraview.delegate = self
        cameraview.setPreviewLayer()
        self.view = cameraview

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.layer.zPosition = -1
        captureSession.startRunning()
        processMotion()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.layer.zPosition = 0
        captureSession.stopRunning()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func determineMaxThumbnails() -> Int {
        let mainViewWidth = Int(self.view.frame.width)
        let imageWidth = 100
        let imageLeadPadding = 10
        let fullImageWidth = Int(imageWidth + imageLeadPadding)
        let maxThumbnailCount:Int = mainViewWidth / fullImageWidth
        print(maxThumbnailCount)
        return maxThumbnailCount
    }
    
    func createPreviewLayer() -> (CGRect?, AVCaptureVideoPreviewLayer?) {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Front }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            self.captureDevice = captureDevice
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
            } catch _ {
                print("error: \(error?.localizedDescription)")
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
            videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
            
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                self.previewLayer = previewLayer
                return (UIScreen.mainScreen().bounds, previewLayer)
            }
        }

        return (nil, nil)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.sharedApplication().statusBarOrientation.rawValue)!
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("no pixelbuffer")
            return
        }
        
        self.newCameraImage(sampleBuffer, image: CIImage(CVPixelBuffer: pixelBuffer))
    }

    func newCameraImage(sampleBuffer: CMSampleBuffer, image: CIImage) {
        let cid:CIDetector = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh]);
        let results:NSArray = cid.featuresInImage(image, options: nil);
        if results.count > 0 {
            faceDetected = true
            let face:CIFaceFeature = results.firstObject as! CIFaceFeature
            print("face found at \(face.bounds.origin.x),\(face.bounds.origin.y) of dimensions \(face.bounds.width)x\(face.bounds.height)")
            
            if vibrated {
                self.vibrated = false
                AudioServicesPlaySystemSound(1108)
                dispatch_async(dispatch_get_main_queue()){
                    if self.captureDevice.focusPointOfInterestSupported{
                        self.captureDevice.focusPointOfInterest = self.previewLayer!.captureDevicePointOfInterestForPoint(face.calculateFaceCenter(face.bounds))
                        self.captureDevice.focusMode = .AutoFocus
                    }
                    print("take photo")
                    let image = sampleBuffer.imageFromSampleBuffer()
//                    (self.view as! CameraView).addThumbnailImage(image)
                    self.thumbNails.append(image)
                    
                    var imagesarray = (self.view as! CameraView).thumbNailGallery.thumbnailGalleryImageViewArray
                    
                    if self.thumbNails.count == 1 {
                        imagesarray[0].image = image
                        imagesarray[0].layoutSubviews()
                    }
                    
                    print("added image")
                }
            }
        }else {
            print("no face detected")
            self.faceDetected = false
        }
    }
    
    func viewAllButtonTapped(sender: UIButton){
        let vc = ThumbnailCollectionViewController()
        vc.thumbnailsArray = thumbNails
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didDragThumbnailImageView(sender: UIPanGestureRecognizer) {
        return
//        if TNImageView.initialPosition == nil {
//            TNImageView.initialPosition = sender.view!.frame.origin
//        }
//        
//        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
//            let translation = sender.translationInView(self.view)
//            sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
//            sender.setTranslation(CGPointMake(0,0), inView: self.view)
//        }
//        
//        if sender.state == .Ended {
//            //detect user intension by looking at where they dragged the thumbnail; trash if dragged any part of image to left or right edge otherwise snap back
//            let doesIntersectLeftEdge = TNImageView.superview!.convertRect(sender.view!.frame, toView: self.view).intersects(CGRectMake(0, 0, 1, view.frame.height))
//            let doesIntersectRightEdge = TNImageView.superview!.convertRect(sender.view!.frame, toView: self.view).intersects(CGRectMake(view.frame.width-1, 0, 1, view.frame.height))
//            
//            if  doesIntersectLeftEdge || doesIntersectRightEdge {
//                let removedImageIndex = thumbNails.removeObject(TNImageView.image!)
//                sender.view?.removeFromSuperview()
//                
//                //need to reset the leading constraint of the images arranged to the right of the image removed
//                //if new image that takes over the old index is 0 then set its leading constraint to the main view's leading edge otherwise set new image at removed index position to the image to its left
//                //but don't do any constraint updates if removing from the end
//                if removedImageIndex! != thumbNails.count {
////                    if removedImageIndex! == 0 {
////                        //then this image is the first thumbnail
////                        self.thumbNails[removedImageIndex!].leadingAnchor.constraintEqualToAnchor(self.thumbNailGallery.leadingAnchor, constant: 10).active = true
////                    } else {
////                        self.thumbNails[removedImageIndex!].leadingAnchor.constraintEqualToAnchor(self.thumbNails[removedImageIndex! - 1].trailingAnchor, constant: 10).active = true
////                    }
//                }
//                
//            }else {
//                //snap back to original spot
//                UIView.animateWithDuration(0.2) { () -> Void in
//                    sender.view!.frame.origin = TNImageView.initialPosition!
//                    TNImageView.initialPosition = nil
//                }
//            }
//        }
    }
    
    func processMotion() {
        var initialAttitude:CMAttitude? = nil
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!) { (deviceMotion, error) in
            if let gravity = deviceMotion?.gravity {
                let runningAngle = self.motionManager.handleAccelerationData(dX: gravity.x, dY: gravity.y)
                
                if initialAttitude == nil {
                    initialAttitude = self.motionManager.deviceMotion!.attitude
                }
                
                //translate the attitude based on starting point
                deviceMotion?.attitude.multiplyByInverseOfAttitude(initialAttitude!)
                let runningMagnitude = self.motionManager.handleAttitudeData((deviceMotion?.attitude)!)
                
                if runningAngle < 160.0 && runningMagnitude > 0.8 && !self.faceDetected && !self.vibrated {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.vibrated = true
                }
            }
        }
    }
}

