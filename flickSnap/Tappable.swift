//
//  Tappable.swift
//  flickSnap
//
//  Created by Stanley Chiang on 7/5/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

protocol Tappable {
    func didTapOnThumbnail(sender: UITapGestureRecognizer)
}

extension Tappable where Self:UIImageView {
    func didTapOnThumbnail(sender: UITapGestureRecognizer){
        let vc = ThumbnailDetailViewController(thumbnail: (sender.view as! ThumbnailImageView).image!)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navigationController.pushViewController(vc, animated: true)
    }
}