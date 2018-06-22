//
//  ViewController.swift
//  WQBanner
//
//  Created by CampbellQi on 2018/6/22.
//  Copyright © 2018年 CampbellQi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bannerView: WQBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var imageUrls: [String] = []
        for i in 1 ... 4 {
            imageUrls.append("timg-\(i).jpeg")
        }
        
        bannerView.imageUrls = imageUrls
        bannerView.autoScrollDuration = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

