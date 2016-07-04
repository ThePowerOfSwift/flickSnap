//
//  ThumbnailDetailViewController.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/2/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class ThumbnailDetailViewController: UIViewController {
    
    var thumbnailDetailView:ThumbnailDetailView!

    init(thumbnail: UIImage){
        let filters = [UIColor.blueColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.redColor()]
        thumbnailDetailView = ThumbnailDetailView(thumbnail: thumbnail, filterArray: filters)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = thumbnailDetailView
    }
    
    override func viewDidLoad() {
        self.navigationController!.navigationBar.layer.zPosition = 0
        setupNavBarSaveButton()
    }
    
    func setupNavBarSaveButton(){
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(self.saveAction(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func saveAction(sender: UIBarButtonItem){
        UIImageWriteToSavedPhotosAlbum(thumbnailDetailView.imageView.image!, nil, #selector(self.imageSaveCompleted(_:)), nil)
    }
    
    func imageSaveCompleted(picker: UIImagePickerController) {
        let alertController = UIAlertController(title: "Image Saved", message: "success!", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateTint(sender: UIButton){
        thumbnailDetailView.imageView.image = thumbnailDetailView.thumbnail.tint(sender.backgroundColor!)
    }
    
}

