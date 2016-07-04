//
//  CMMotionManagerExtensions.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import CoreMotion

extension CMMotionManager {
    func convertCoordToDegrees(a a:Double, b:Double) -> Double{
        let rad = atan2(a, b)
        let deg = rad * 180 / M_PI
        
        return deg
    }
    
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
    
    func handleAccelerationData(dX dX:Double, dY: Double) -> Double {
        let testAngle = convertCoordToDegrees(a: dX, b: dY)
        return abs(testAngle)
    }
    
    func handleAttitudeData(attitude: CMAttitude) -> Double {
        // calculate magnitude of the change from our initial attitude
        let magnitude = self.magnitudeFromAttitude(attitude) ?? 0
        return magnitude
    }
    
}
