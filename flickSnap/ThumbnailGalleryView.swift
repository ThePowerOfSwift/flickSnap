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
    var maxThumbnails:Int!
    
    let viewallButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        maxThumbnails = determineMaxThumbnails()
        
        for _ in 1 ... maxThumbnails - 1 {
            let imageView = ThumbnailImageView(frame: CGRectZero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            thumbnailGalleryImageViewArray.append(imageView)
        }
        
        
        viewallButton.translatesAutoresizingMaskIntoConstraints = false
        viewallButton.addTarget(self, action: #selector(self.viewallButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewallButton.setTitle("View All", forState: UIControlState.Normal)
        viewallButton.alpha = 0
        addSubview(viewallButton)
        
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
            
            if index == thumbnailGalleryImageViewArray.count - 1 {
                viewallButton.leadingAnchor.constraintEqualToAnchor((thumbnailGalleryImageViewArray[index] as ThumbnailImageView).trailingAnchor, constant: 10).active = true
                viewallButton.topAnchor.constraintEqualToAnchor(viewallButton.superview!.topAnchor).active = true
                viewallButton.bottomAnchor.constraintEqualToAnchor(viewallButton.superview!.bottomAnchor).active = true
                viewallButton.widthAnchor.constraintEqualToAnchor(viewallButton.superview!.heightAnchor).active = true
                
            }
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

    func viewallButtonTapped(sender: UIButton){
        let vc = ThumbnailCollectionViewController()
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        vc.thumbnailsArray = appDelegate.thumbNails
        appDelegate.navigationController.pushViewController(vc, animated: true)
        print("open collection view")
    }
    
}
