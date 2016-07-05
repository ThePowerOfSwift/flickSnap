//
//  ThumbnailGalleryView.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/5/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailGalleryView: UIView {
    
    var thumbnailGalleryImageViewArray = [ThumbnailImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        for _ in 1 ... determineMaxThumbnails() - 1 {
            let imageView = ThumbnailImageView(frame: CGRectMake(0, 0, 50, 50))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            thumbnailGalleryImageViewArray.append(imageView)
//            imageView.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        leadingAnchor.constraintEqualToAnchor(self.superview!.leadingAnchor).active = true
        trailingAnchor.constraintEqualToAnchor(self.superview!.trailingAnchor).active = true
        bottomAnchor.constraintEqualToAnchor(self.superview!.bottomAnchor, constant: -10).active = true
        heightAnchor.constraintEqualToConstant(100).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func determineMaxThumbnails() -> Int {
        let mainViewWidth = Int(UIScreen.mainScreen().bounds.width)
        let imageWidth = 100
        let imageLeadPadding = 10
        let fullImageWidth = Int(imageWidth + imageLeadPadding)
        let maxThumbnailCount:Int = mainViewWidth / fullImageWidth
        print(maxThumbnailCount)
        return maxThumbnailCount
    }

}
