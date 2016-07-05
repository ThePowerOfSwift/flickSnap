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
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice!
    var error: NSError?

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
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.removeImage(_:)), name: "imageRemoved", object: nil)
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
//            print("face found at \(face.bounds.origin.x),\(face.bounds.origin.y) of dimensions \(face.bounds.width)x\(face.bounds.height)")
            
            if vibrated {
                dispatch_async(dispatch_get_main_queue()){
                    if self.captureDevice.focusPointOfInterestSupported{
                        self.captureDevice.focusPointOfInterest = self.previewLayer!.captureDevicePointOfInterestForPoint(face.calculateFaceCenter(face.bounds))
                        self.captureDevice.focusMode = .AutoFocus
                    }
                    
                    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let image = sampleBuffer.imageFromSampleBuffer()
                    
                    appDelegate.thumbNails.append(image)
                    print(appDelegate.thumbNails.count)
                    AudioServicesPlaySystemSound(1108)
                    
                    let tnGallery = (self.view as! CameraView).thumbNailGallery
                    var imagesarray = (self.view as! CameraView).thumbNailGallery.thumbnailGalleryImageViewArray
                    
                    if appDelegate.thumbNails.count < tnGallery.maxThumbnails {
                        for (index, _) in appDelegate.thumbNails.enumerate() {
                            imagesarray[index].image = appDelegate.thumbNails[index]
                        }
                    }else {
                        tnGallery.viewallButton.alpha = 1
                        
                        imagesarray[imagesarray.count - 2].image = appDelegate.thumbNails[appDelegate.thumbNails.count - 2]
                        imagesarray[imagesarray.count - 1].image = appDelegate.thumbNails[appDelegate.thumbNails.count - 1]
                    }
                    
                    print("added image")
                }
                self.vibrated = false
            }
        }else {
            self.faceDetected = false
        }
    }
    
    func removeImage(sender: NSNotification){
        print("remove from camera vc")
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

