//
//  CGRectExtensions.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

extension CIFaceFeature {
    func calculateFaceCenter(bounds: CGRect) -> CGPoint{
        let centerX = bounds.origin.x + bounds.width / 2.0
        let centerY = bounds.origin.y + bounds.width / 2.0
        
        return CGPoint(x: centerX, y: centerY)
    }
}

