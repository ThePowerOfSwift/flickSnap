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
    
    var scrollView:UIScrollView!
    var stackView:UIStackView!
    
    override func viewDidLoad() {
        setupImageView()
        setupFilterView()
        setupScrollingStackView()
    }
    
    func setupImageView(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = thumbnail
        self.view.addSubview(imageView)
//        imageView.image = imageView.image?.tint(UIColor.yellowColor())
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

    func setupScrollingStackView(){
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        filterView.addSubview(scrollView)
        
        scrollView.topAnchor.constraintEqualToAnchor(filterView.topAnchor).active = true
        scrollView.leadingAnchor.constraintEqualToAnchor(filterView.leadingAnchor).active = true
        scrollView.trailingAnchor.constraintEqualToAnchor(filterView.trailingAnchor).active = true
        scrollView.bottomAnchor.constraintEqualToAnchor(filterView.bottomAnchor).active = true
        
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: .AlignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: .AlignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))

        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Horizontal
        scrollView.addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true

        
//        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["stackView": stackView]))
//        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stackView]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["stackView": stackView]))

        let blueFilter = UIButton()
        blueFilter.backgroundColor = UIColor.blueColor()
        blueFilter.addTarget(self, action: #selector(self.updateTint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        blueFilter.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(blueFilter)
        blueFilter.heightAnchor.constraintEqualToAnchor(filterView.heightAnchor).active = true
        blueFilter.widthAnchor.constraintEqualToAnchor(blueFilter.heightAnchor).active = true
        
        let yellowFilter = UIButton()
        yellowFilter.backgroundColor = UIColor.yellowColor()
        yellowFilter.addTarget(self, action: #selector(self.updateTint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        yellowFilter.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(yellowFilter)
        yellowFilter.heightAnchor.constraintEqualToAnchor(filterView.heightAnchor).active = true
        yellowFilter.widthAnchor.constraintEqualToAnchor(yellowFilter.heightAnchor).active = true
        
        let greenFilter = UIButton()
        greenFilter.backgroundColor = UIColor.greenColor()
        greenFilter.addTarget(self, action: #selector(self.updateTint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        greenFilter.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(greenFilter)
        greenFilter.heightAnchor.constraintEqualToAnchor(filterView.heightAnchor).active = true
        greenFilter.widthAnchor.constraintEqualToAnchor(greenFilter.heightAnchor).active = true
        
        let redFilter = UIButton()
        redFilter.backgroundColor = UIColor.redColor()
        redFilter.addTarget(self, action: #selector(self.updateTint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        redFilter.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(redFilter)
        redFilter.heightAnchor.constraintEqualToAnchor(filterView.heightAnchor).active = true
        redFilter.widthAnchor.constraintEqualToAnchor(redFilter.heightAnchor).active = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    func updateTint(sender: UIButton){
        imageView.image = thumbnail.tint(sender.backgroundColor!)
    }
}

extension UIImage {
    
    //https://gist.github.com/fabb/007d30ba0759de9be8a3
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            CGContextSetBlendMode(context, .Normal)
            UIColor.blackColor().setFill()
            CGContextFillRect(context, rect)
            
            // draw original image
            CGContextSetBlendMode(context, .Normal)
            CGContextDrawImage(context, rect, self.CGImage)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            CGContextSetBlendMode(context, .Color)
            tintColor.setFill()
            CGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            CGContextSetBlendMode(context, .DestinationIn)
            CGContextDrawImage(context, rect, self.CGImage)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            CGContextSetBlendMode(context, .Normal)
            fillColor.setFill()
            CGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            CGContextSetBlendMode(context, .DestinationIn)
            CGContextDrawImage(context, rect, self.CGImage)
        }
    }
    
    private func modifiedImage(@noescape draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}