//
//  ViewController.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit


class ViewController: UIViewController {

    fileprivate func mergeVideoImageText() {
        let urlVideo = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        
        
        let videoData = MergeVideoInfo()
        videoData.isVideo = true
        videoData.asset = AVAsset(url: urlVideo!)
        
        let imageData = MergeVideoInfo()
        imageData.isVideo = false
        imageData.image = #imageLiteral(resourceName: "n1")
        
        let textData = TextInfo()
        textData.text = "HELLO WORLD"
        textData.fontSize = 50
        textData.textColor = UIColor.blue
        textData.showTime = 3 // Second
        textData.endTime = 5 // Second
        textData.textFrame = CGRect(x: 0, y: 0, width: 400, height: 300)
        
        
        
        let merge = MergeVideoWithTextVideoManager()
        
        merge.makeVideoFrom(data: [videoData, imageData], textData: [textData]) { (url, error) in
            
            debugPrint(url)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mergeVideoImageText()
//        mergeTwoVideosToOneVideo()
        
        
    
    }

    
    fileprivate func mergeTwoVideosToOneVideo() {
        
        let urlVideo1 = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let urlVideo2 = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        
        let avVideo1 = AVAsset(url: urlVideo1!)
        let avVideo2 = AVAsset(url: urlVideo2!)
        
        let merge = MergeVideoToVideoManager()
        merge.doMerge(arrayVideos:  [avVideo1, avVideo2], animation: true) { (url, error) in
            
              debugPrint(url)
        }
        
       
    }


}

