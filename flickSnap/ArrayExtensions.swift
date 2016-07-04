//
//  ArrayExtensions.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

extension Array where Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) -> Int? {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
            return index
        } else {
            return nil
        }
        
    }
}

