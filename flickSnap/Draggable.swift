//
//  Draggable.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/5/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

protocol Draggable {
    func didDragOnThumbnail(initialPosition:CGPoint?, sender: UIPanGestureRecognizer)
}

extension Draggable where Self:UIImageView {
    
    func didDragOnThumbnail( initialPosition: CGPoint?, sender: UIPanGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            let translation = sender.translationInView(sender.view?.superview?.superview)
            sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
            sender.setTranslation(CGPointMake(0,0), inView: sender.view?.superview?.superview)
        }
        
        if sender.state == .Ended {
            let doesIntersectLeftEdge = self.superview!.convertRect(sender.view!.frame, toView: sender.view?.superview?.superview).intersects(CGRectMake(0, 0, 1, UIScreen.mainScreen().bounds.height))
            let doesIntersectRightEdge = self.superview!.convertRect(sender.view!.frame, toView: sender.view?.superview?.superview).intersects(CGRectMake(UIScreen.mainScreen().bounds.width-1, 0, 1, UIScreen.mainScreen().bounds.height))
            
            if doesIntersectLeftEdge || doesIntersectRightEdge {
                (sender.view as? UIImageView)!.image = nil
                sender.view!.frame.origin = initialPosition!
            }else {
                UIView.animateWithDuration(0.24) { () -> Void in
                    sender.view!.frame.origin = initialPosition!
                }
            }
        }
    }
}