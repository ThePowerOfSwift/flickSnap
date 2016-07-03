//
//  ThumbnailCollectionViewController.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/2/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var thumbnailsArray:[UIImageView]!
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //returns the navbar to the top layer so that user can access back button
        self.navigationController!.navigationBar.layer.zPosition = 0
        view.backgroundColor = UIColor.orangeColor()
        addCollectionView()
    }
    
    // MARK: UICollectionViewDataSource
    
    func addCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.backgroundColor = UIColor.cyanColor()
        view.addSubview(collectionView!)
        addCollectionViewConstraints()
    }
    
    func addCollectionViewConstraints() {
        collectionView?.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        collectionView?.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        collectionView?.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        collectionView?.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        //        NSLayoutConstraint.activate([horizontalConstraint!,bottomConstraint!,leadingConstraint!,trailingConstraint!])
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let sideLength = self.view.frame.width / 2.0
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        
        let image:UIImage = thumbnailsArray[indexPath.row].image!
        let imageView:UIImageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)
        
        imageView.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor).active = true
        imageView.leadingAnchor.constraintEqualToAnchor(cell.contentView.leadingAnchor).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(cell.contentView.trailingAnchor).active = true
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = ThumbnailDetailViewController()
        vc.thumbnail = thumbnailsArray[indexPath.row].image
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
