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

class ViewController: UIViewController {

    var motionManager:MotionManager = MotionManager()
    var angleLabel:UILabel = UILabel()
    var magnitudeLabel:UILabel = UILabel()
    var initialAttitude:CMAttitude?
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Front }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            
//            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
            } catch _ {
                print("error: \(error?.localizedDescription)")
            }
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
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
        
        view.addSubview(angleLabel)
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        angleLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        angleLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        angleLabel.intrinsicContentSize()
        angleLabel.text = "angelLabel"
        
        view.addSubview(magnitudeLabel)
        magnitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        magnitudeLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        magnitudeLabel.topAnchor.constraintEqualToAnchor(angleLabel.bottomAnchor, constant: 10).active = true
        magnitudeLabel.intrinsicContentSize()
        magnitudeLabel.text = "attitudeLabel"
        
        processMotion()
        
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
                
                if runningAngle < 170.0 && runningMagnitude > 0.5 {
                    self.view.backgroundColor = UIColor.greenColor()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    print("ready for capture")
                } else {
                    self.view.backgroundColor = UIColor.whiteColor()
                    if (self.captureSession.running) {
                        self.saveToCamera()
                        print("capture")
                        //Custom capture method.
                    }
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
        angleLabel.text = "\(abs(testAngle))"
        return abs(testAngle)
    }
    
    func handleAttitudeData(attitude: CMAttitude) -> Double {
        // calculate magnitude of the change from our initial attitude
        let magnitude = self.magnitudeFromAttitude(attitude) ?? 0
        magnitudeLabel.text = "\(magnitude)"
        return magnitude
    }
}

