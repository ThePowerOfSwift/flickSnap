//
//  MotionManager.swift
//  flickSnap
//
//  Created by Stanley Chiang on 6/30/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import CoreMotion

class MotionManager: CMMotionManager {
    func convertCoordToDegrees(a a:Double, b:Double) -> Double{
        let rad = atan2(a, b)
        let deg = rad * 180 / M_PI
        
        return deg
    }
}
