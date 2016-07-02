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
    
    var useCamera:Bool = true
    var useMotion:Bool = true
    var useCapture:Bool = false
    var useLabels:Bool = true
//    var faceDetected:Bool = true
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()
        
        if useCamera {
            let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Front }
            if let captureDevice = devices.first as? AVCaptureDevice  {

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
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if captureSession.canAddOutput(stillImageOutput) {
//                    captureSession.addOutput(stillImageOutput)
                    captureSession.addOutput(videoOutput)
                }
                if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                    previewLayer.bounds = view.bounds
                    previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
                    cameraPreview.layer.addSublayer(previewLayer)
                    //                cameraPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"saveToCamera:"))
                    view.addSubview(cameraPreview)
                }
            }
        }
        
        if useMotion {
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
    }
    
    func saveToCamera() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            }
        }
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
                
//                print("\(deviceMotion!.userAcceleration.x) | \(deviceMotion!.userAcceleration.y) | \(deviceMotion!.userAcceleration.x)")
                
                if runningAngle < 170.0 && runningMagnitude > 0.5 {
//                    self.view.backgroundColor = UIColor.greenColor()
                    if !self.vibrated {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        self.vibrated = true
                    }
                    print("ready")
                }
//                else if deviceMotion?.userAcceleration.x < 0.25 {
////                    self.view.backgroundColor = UIColor.whiteColor()
//                    
//                    if self.captureSession.running && self.vibrated {
//                        self.vibrated = false
//                        if self.useCapture {
//                            //Custom capture method.
////                            self.saveToCamera()
////                            print("capture \(deviceMotion!.userAcceleration.x) | \(deviceMotion!.userAcceleration.y) | \(deviceMotion!.userAcceleration.x)")
//                        }
//                    }
//                }
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
        
//        dispatch_async(dispatch_get_main_queue()){
            self.newCameraImage(sampleBuffer, image: CIImage(CVPixelBuffer: pixelBuffer))
//        }
    }
    
    func newCameraImage(sampleBuffer: CMSampleBuffer, image: CIImage) {
        let cid:CIDetector = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh]);
        let results:NSArray = cid.featuresInImage(image, options: nil);
        if results.count > 0 {
            let face:CIFaceFeature = results.firstObject as! CIFaceFeature
            print("face found at \(face.bounds.origin.x),\(face.bounds.origin.y) of dimensions \(face.bounds.width)x\(face.bounds.height)")
            
            //save photo
            if vibrated {
                dispatch_async(dispatch_get_main_queue()){
                    AudioServicesPlaySystemSound(1108)
                    UIImageWriteToSavedPhotosAlbum(self.imageFromSampleBuffer(sampleBuffer), nil, nil, nil)
                    self.vibrated = false
//                    AudioServicesPlaySystemSound(1108)
                }
            }
        }else {
            print("no face detected")
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
}

