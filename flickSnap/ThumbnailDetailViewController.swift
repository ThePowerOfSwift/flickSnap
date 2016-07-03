//
//  ThumbnailDetailViewController.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/2/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailDetailViewController: UIViewController {
    
    var thumbnail:UIImage!
    var imageView:UIImageView = UIImageView()
    var filterView:UIView = UIView()
    
    override func viewDidLoad() {
        setupImageView()
        setupFilterView()
    }
    
    func setupImageView(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = thumbnail
        self.view.addSubview(imageView)
        
        imageView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        imageView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        //        imageView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: 100).active = true
        NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.75, constant: 0).active = true
    }
    
    func setupFilterView(){
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.backgroundColor = UIColor.cyanColor()
        self.view.addSubview(filterView)
        
        filterView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
        filterView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        filterView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        filterView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
    }

}
