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
        backgroundColor = UIColor.cyanColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 1 ... determineMaxThumbnails() - 1 {
            let imageView = ThumbnailImageView(frame: CGRectZero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            thumbnailGalleryImageViewArray.append(imageView)
        }
    }
    
    override func layoutSubviews() {
        for (index, tn) in thumbnailGalleryImageViewArray.enumerate() {
            if index == 0 {
                tn.leadingAnchor.constraintEqualToAnchor(tn.superview!.leadingAnchor, constant: 10).active = true
            }else {
                tn.leadingAnchor.constraintEqualToAnchor((thumbnailGalleryImageViewArray[index - 1] as ThumbnailImageView).trailingAnchor, constant: 10).active = true
            }
            tn.topAnchor.constraintEqualToAnchor(tn.superview!.topAnchor).active = true
            tn.bottomAnchor.constraintEqualToAnchor(tn.superview!.bottomAnchor).active = true
            tn.widthAnchor.constraintEqualToAnchor(tn.superview!.heightAnchor).active = true
        }
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
