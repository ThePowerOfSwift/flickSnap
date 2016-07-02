//
//  ViewController.swift
//  flickSnap
//
//  Created by Stanley Chiang on 6/30/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import CoreMotion
import AudioToolbox
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var motionManager:MotionManager = MotionManager()
    var angleLabel:UILabel = UILabel()
    var magnitudeLabel:UILabel = UILabel()
    var initialAttitude:CMAttitude?
    
    var vibrated:Bool = false
    var faceDetected:Bool = true
    
    var useLabels:Bool = false
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice:AVCaptureDevice!
    
    var error: NSError?
    
    var thumbNails = [UIImageView]()
    var thumbNailGallery = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()
        
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
            captureSession.startRunning()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer.bounds = view.bounds
                previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
                cameraPreview.layer.addSublayer(previewLayer)
                view.addSubview(cameraPreview)
                self.previewLayer = previewLayer
                
                setupThumbnailView()
                
            }
        }
        
        if useLabels {
            view.addSubview(angleLabel)
            angleLabel.translatesAutoresizingMaskIntoConstraints = false
            angleLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
            angleLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
            angleLabel.intrinsicContentSize()
            angleLabel.text = "angelLabel"
            angleLabel.backgroundColor = UIColor.lightGrayColor()
            
            view.addSubview(magnitudeLabel)
            magnitudeLabel.translatesAutoresizingMaskIntoConstraints = false
            magnitudeLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
            magnitudeLabel.topAnchor.constraintEqualToAnchor(angleLabel.bottomAnchor, constant: 10).active = true
            magnitudeLabel.intrinsicContentSize()
            magnitudeLabel.text = "attitudeLabel"
            magnitudeLabel.backgroundColor = UIColor.lightGrayColor()
        }
        
        processMotion()
    }
    
    func setupThumbnailView(){

        view.addSubview(thumbNailGallery)
        
        thumbNailGallery.translatesAutoresizingMaskIntoConstraints = false
        thumbNailGallery.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 10).active = true
        thumbNailGallery.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        thumbNailGallery.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -10).active = true
        thumbNailGallery.heightAnchor.constraintEqualToConstant(100).active = true
        
    }
    
    func processMotion(){
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!) { (deviceMotion, error) in
            if let gravity = deviceMotion?.gravity {
                let runningAngle = self.handleAccelerationData(dX: gravity.x, dY: gravity.y)
                
                if self.initialAttitude == nil {
                    self.initialAttitude = self.motionManager.deviceMotion!.attitude
                }
                
                //translate the attitude based on starting point
                deviceMotion?.attitude.multiplyByInverseOfAttitude(self.initialAttitude!)
                let runningMagnitude = self.handleAttitudeData((deviceMotion?.attitude)!)
                
                if runningAngle < 160.0 && runningMagnitude > 0.8 && !self.faceDetected && !self.vibrated {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.vibrated = true
                }
            }
        }
    }

    // get magnitude of vector via Pythagorean theorem
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
    
    func stopMotion(){
        motionManager.stopAccelerometerUpdates()
    }

    func handleAccelerationData(dX dX:Double, dY: Double) -> Double {
        let testAngle = motionManager.convertCoordToDegrees(a: dX, b: dY)
        if useLabels {
            angleLabel.text = "\(abs(testAngle))"
        }

        return abs(testAngle)
    }
    
    func handleAttitudeData(attitude: CMAttitude) -> Double {
        // calculate magnitude of the change from our initial attitude
        let magnitude = self.magnitudeFromAttitude(attitude) ?? 0
        if useLabels {
            magnitudeLabel.text = "\(magnitude)"
        }
        
        return magnitude
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
            
            
            //save photo
            if vibrated {
                self.vibrated = false
                AudioServicesPlaySystemSound(1108)
                dispatch_async(dispatch_get_main_queue()){
                    if self.captureDevice.focusPointOfInterestSupported{
                        self.captureDevice.focusPointOfInterest = self.previewLayer.captureDevicePointOfInterestForPoint(self.calculateFaceCenter(face.bounds))
                        self.captureDevice.focusMode = .AutoFocus
                    }
                    
                    let imageView = UIImageView(image: self.imageFromSampleBuffer(sampleBuffer))
                    imageView.userInteractionEnabled = true
                    imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragImage(_:))))
                    
                    
                    self.thumbNails.append(imageView)
                    self.thumbNailGallery.addSubview(imageView)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    if self.thumbNails.count == 1 {
                        //then this image is the first thumbnail
                        self.thumbNails.last?.leadingAnchor.constraintEqualToAnchor(self.thumbNailGallery.leadingAnchor).active = true
                    } else {
                        self.thumbNails.last?.leadingAnchor.constraintEqualToAnchor(self.thumbNails[self.thumbNails.count - 2].trailingAnchor, constant: 10).active = true
                    }

                    self.thumbNails.last?.topAnchor.constraintEqualToAnchor(self.thumbNailGallery.topAnchor).active = true
                    self.thumbNails.last?.bottomAnchor.constraintEqualToAnchor(self.thumbNailGallery.bottomAnchor).active = true
                    self.thumbNails.last?.widthAnchor.constraintEqualToAnchor(self.thumbNailGallery.heightAnchor).active = true
                    
                    //need to somehow detect if adding another image would be cut off the page and instead insert a "view all" option
                    
                    
//                    UIImageWriteToSavedPhotosAlbum(self.imageFromSampleBuffer(sampleBuffer), nil, nil, nil)
                    
                    
                }
            }
        }else {
            print("no face detected")
            self.faceDetected = false
        }
    }
    
    func imageFromSampleBuffer(sampleBuffer:CMSampleBuffer!) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo:CGBitmapInfo = [.ByteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)]
        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let quartzImage = CGBitmapContextCreateImage(context)
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        
        let image = UIImage(CGImage: quartzImage!)
        return image
    }
    
    func calculateFaceCenter(bounds: CGRect) -> CGPoint{
        let centerX = bounds.origin.x + bounds.width / 2.0
        let centerY = bounds.origin.y + bounds.width / 2.0
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    func dragImage(sender: UIPanGestureRecognizer){
        print("dragging")
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            print("began | changed")
            let translation = sender.translationInView(self.view)
            // note: 'view' is optional and need to be unwrapped
            sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
            sender.setTranslation(CGPointMake(0,0), inView: self.view)
        }
    }
}
