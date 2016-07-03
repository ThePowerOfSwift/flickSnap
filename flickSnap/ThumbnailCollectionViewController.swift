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
//        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.registerClass(ThumbnailCell.self, forCellWithReuseIdentifier: "Cell")
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
        return CGSize(width: 50,height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        let image:UIImageView = thumbnailsArray[indexPath.row]
        image.contentMode = .ScaleAspectFit
        cell.contentView.addSubview(image)

        image.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor).active = true
        image.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor).active = true
        image.leadingAnchor.constraintEqualToAnchor(cell.contentView.leadingAnchor).active = true
        image.trailingAnchor.constraintEqualToAnchor(cell.contentView.trailingAnchor).active = true
        
        // Configure the cell
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selected index: #\(indexPath.row)")
    }
    
    

}
