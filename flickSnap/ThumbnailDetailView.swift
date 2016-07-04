//
//  ThumbnailDetailView.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/3/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailDetailView: UIView {
    
    var thumbnail:UIImage!
    var filterArray:[UIColor]!
    
    var imageView = UIImageView()
    var filterView = UIView()
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    
    var buttonArray = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(filterView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addSubview(scrollView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Horizontal
        scrollView.addSubview(stackView)
        
    }
    
    convenience init(thumbnail: UIImage, filterArray:[UIColor]){
        self.init()
        self.thumbnail = thumbnail
        self.imageView.image = thumbnail
        self.filterArray = filterArray
        for filter in filterArray {
            let filterButton = UIButton()
            buttonArray.append(filterButton)
            filterButton.backgroundColor = filter
            filterButton.addTarget(nil, action: #selector(ThumbnailDetailViewController.updateTint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            filterButton.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(filterButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setupImageViewConstraints()
        setupFilterViewConstraints()
        setupScrollingStackViewConstraints()
    }

    func setupImageViewConstraints(){
        
//        imageView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(superview!.topAnchor).active = true
        imageView.leadingAnchor.constraintEqualToAnchor(superview!.leadingAnchor).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(superview!.trailingAnchor).active = true
        NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: superview!, attribute: .Height, multiplier: 0.75, constant: 0).active = true
    
    }
    
    func setupFilterViewConstraints(){
        filterView.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
        filterView.leadingAnchor.constraintEqualToAnchor(superview!.leadingAnchor).active = true
        filterView.trailingAnchor.constraintEqualToAnchor(superview!.trailingAnchor).active = true
//        filterView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        filterView.bottomAnchor.constraintEqualToAnchor(superview!.bottomAnchor).active = true
        
    }
    
    func setupScrollingStackViewConstraints(){
        scrollView.topAnchor.constraintEqualToAnchor(filterView.topAnchor).active = true
        scrollView.leadingAnchor.constraintEqualToAnchor(filterView.leadingAnchor).active = true
        scrollView.trailingAnchor.constraintEqualToAnchor(filterView.trailingAnchor).active = true
        scrollView.bottomAnchor.constraintEqualToAnchor(filterView.bottomAnchor).active = true
        
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
        
        stackView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true
        
        for button in buttonArray {
            button.heightAnchor.constraintEqualToAnchor(filterView.heightAnchor).active = true
            button.widthAnchor.constraintEqualToAnchor(button.heightAnchor).active = true
        }
        
    }

}