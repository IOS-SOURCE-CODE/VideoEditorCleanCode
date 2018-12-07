//
//  PreviewViewController.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 5/12/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       generateSingleImageFromVideoFrame()
        
//        test()
        generateSequenceImageFromVideoFrame()
        
    }
    
    func generateSequenceImageFromVideoFrame() {
        let urlVideo = Bundle.main.url(forResource: "movie1", withExtension: "mov")!
        let asset = AVURLAsset(url: urlVideo)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let durationSecond: Float64 = CMTimeGetSeconds(asset.duration)
        let firstThird: CMTime = CMTimeMakeWithSeconds(durationSecond/3.0, 600)
        let secondThird: CMTime = CMTimeMakeWithSeconds((durationSecond*2.0)/3.0, 600)
        let end: CMTime = CMTimeMakeWithSeconds(durationSecond, 600)
        let times = [NSValue(time: kCMTimeZero), NSValue(time: firstThird),  NSValue(time: secondThird),  NSValue(time: end)]
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, cgimage, actualTime, result, error) in
            
            print(requestedTime.value, requestedTime.seconds, actualTime.value)
            DispatchQueue.main.async {
                if let image = cgimage {
                    self.videoImageView.image = UIImage(cgImage: image)
                }
            }
        }
    }
    
    func generateSequenceImageSampleCountFromVideoFrame() {
        if let path = Bundle.main.url(forResource: "movie1", withExtension: "mov") {
//            let fileUrl  = NSURL(fileURLWithPath: path)
            let asset = AVURLAsset(url: path, options: nil)
            let videoDuration = asset.duration
            
            let generator = AVAssetImageGenerator(asset: asset)
            
            var frameForTimes = [NSValue]()
            let sampleCounts = 20
            let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
            let step = totalTimeLength / sampleCounts
            
            for i in 0 ..< sampleCounts {
                let cmTime = CMTimeMake(Int64(i * step), Int32(videoDuration.timescale))
                frameForTimes.append(NSValue(time: cmTime))
            }
            
            generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime, image, actualTime, result, error in
                DispatchQueue.main.async {
                    if let image = image {
                        print(requestedTime.value, requestedTime.seconds, actualTime.value)
                        self.videoImageView.image = UIImage(cgImage: image)
                    }
                }
            })
        }
    }
    
    func generateSingleImageFromVideoFrame() {
        let urlVideo = Bundle.main.url(forResource: "movie1", withExtension: "mov")!
        let asset = AVURLAsset(url: urlVideo)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        var cgImage: CGImage?
        do {
            cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
        } catch let error as NSError {
            // Handle the error
            print(error)
        }
        // Handle the nil that cgImage might be
        let uiImage = UIImage(cgImage: cgImage!)
        videoImageView.image = uiImage
    }
}

