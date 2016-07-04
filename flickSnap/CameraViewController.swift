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
    
    var cameraview: CameraView!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice!
    var error: NSError?

    var thumbNails = [UIImageView]()
    
    let motionManager = CMMotionManager()
    var vibrated = false
    var faceDetected:Bool = true

    override func loadView() {
        super.loadView()
        cameraview = CameraView()
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
                }
                
                print("take photo")
                
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
    
    func thumbnailTapped(sender:UITapGestureRecognizer) {
        let vc = ThumbnailDetailViewController(thumbnail: (sender.view as! UIImageView).image!)
        navigationController?.pushViewController(vc, animated: true)
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

