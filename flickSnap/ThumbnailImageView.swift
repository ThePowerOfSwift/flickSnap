//
//  ThumbnailImageView.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailImageView: UIImageView, Draggable, Tappable {
    var initialPosition:CGPoint? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.redColor().CGColor
        layer.borderWidth = 2
        translatesAutoresizingMaskIntoConstraints = false
        userInteractionEnabled = true
        contentMode = .ScaleAspectFit
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.thumbnailTapped(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dragImage(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
//    override func layoutSubviews() {
//        leadingAnchor.constraintEqualToAnchor(self.superview!.leadingAnchor, constant: 10).active = true
//        topAnchor.constraintEqualToAnchor(self.superview!.topAnchor).active = true
//        bottomAnchor.constraintEqualToAnchor(self.superview!.bottomAnchor).active = true
//        widthAnchor.constraintEqualToAnchor(self.superview!.heightAnchor).active = true
//    }
    
    func dragImage(sender: UIPanGestureRecognizer) {
        if initialPosition == nil {
            initialPosition = self.frame.origin    
        }
        
        didDragOnThumbnail(initialPosition,sender: sender)
    }
    
    func thumbnailTapped(sender: UITapGestureRecognizer) {
        didTapOnThumbnail(sender)
    }
    
    
}
