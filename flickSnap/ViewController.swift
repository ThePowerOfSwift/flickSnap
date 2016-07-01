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

class ViewController: UIViewController {

    var motionManager:MotionManager = MotionManager()
    var angleLabel:UILabel = UILabel()
    var magnitudeLabel:UILabel = UILabel()
    var initialAttitude:CMAttitude?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()

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
                    print("capture")
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

