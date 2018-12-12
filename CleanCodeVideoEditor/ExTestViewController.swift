//
//  ExTestViewController.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 11/12/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension TestViewController : MakeTextLayerable {
    func implmentWholeProcessStep2() {
        
        let imageDuration = 5.0
        
        // Create composition and video track, audio track in to composition
        let mutableComposition = AVMutableComposition()
        let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let secondVideoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let blackVideoTrack = mutableComposition.addMutableTrack(withMediaType: .video,preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let audioCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // Load video asset
        let firstVideoUrl = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let firstVideoAsset = AVAsset(url: firstVideoUrl!)
        
        let secondVideoUrl = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        let secondVideoAsset = AVAsset(url: secondVideoUrl!)
        
        let blackVideoUrl = Bundle.main.url(forResource: "black", withExtension: "mov")
        let blackVideoAsset = AVAsset(url: blackVideoUrl!)
        
        // load track from video asset
        let firstVideoAssetTrack = firstVideoAsset.tracks(withMediaType: .video).first!
        let secondVideoAssertTrack = secondVideoAsset.tracks(withMediaType: .video).first!
        let blackVideoAssetTrack = blackVideoAsset.tracks(withMediaType: .video).first!
        
        // Add loaded track from video asset to video composition track
        let firstVideoTimeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
        let secondVideoTimeRange = CMTimeRangeMake(kCMTimeZero,secondVideoAssertTrack.timeRange.duration)

        
        let itemDuration = CMTime(seconds:imageDuration, preferredTimescale: blackVideoAsset.duration.timescale)
        let blackVideoTimeRange = CMTimeRangeMake(kCMTimeZero,blackVideoAssetTrack.timeRange.duration)
        
        try! videoCompositionTrack?.insertTimeRange(firstVideoTimeRange, of: firstVideoAssetTrack, at: kCMTimeZero)
        try! secondVideoCompositionTrack?.insertTimeRange(secondVideoTimeRange, of: secondVideoAssertTrack, at: firstVideoAssetTrack.timeRange.duration)
        
        let startBlackPoint = CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration)
        try! blackVideoTrack?.insertTimeRange(blackVideoTimeRange, of: blackVideoAssetTrack, at: startBlackPoint)
        
        // Load audio
        let urlMusic = Bundle.main.url(forResource: "creativeminds", withExtension: "mp3")
        let musicAsset = AVAsset(url: urlMusic!)
        
        // Get audio track
        let musicTrack = musicAsset.tracks(withMediaType: .audio).first!
        let audioDuration = CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration)
        let tempDuration = CMTimeAdd(audioDuration, blackVideoAssetTrack.timeRange.duration)
//        let addmoreAudioDuration = CMTimeAdd(audioDuration, itemDuration)
        let musicTimeRange = CMTimeRange(start: kCMTimeZero, duration: tempDuration)
        try! audioCompositionTrack?.insertTimeRange(musicTimeRange, of: musicTrack, at: kCMTimeZero)
        
        
        
        // Check Video Portrail and Landscade
        var firstVideoPortrait = false
        let firstTransform = firstVideoAssetTrack.preferredTransform
        if firstTransform.a == 0 && firstTransform.d == 0 &&
            (firstTransform.b == 1.0 || firstTransform.b == -1.0)
            && (firstTransform.c == 1.0 || firstTransform.c == -1.0) {
            firstVideoPortrait = true
            print("firstVideoPortrait")
        } else {
            print("firstVideoPortrait is landscade")
        }
        
        var secondVideoPortrait = false
        let secondTransform = firstVideoAssetTrack.preferredTransform
        if secondTransform.a == 0 && secondTransform.d == 0 &&
            (secondTransform.b == 1.0 || secondTransform.b == -1.0) &&
            (secondTransform.c == 1.0 || secondTransform.c == -1.0) {
            secondVideoPortrait = true
            print("secondVideoPortrait")
        } else {
            print("secondVideoPortrait is landscade")
        }
        
        
        if (firstVideoPortrait && !secondVideoPortrait) || (!firstVideoPortrait && secondVideoPortrait) {
            print("Cannot combile video")
        }
        
        
        // Applying the Video Composition Instructions
        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
        let tempTwo = CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration)
        let tempThree = CMTimeAdd(tempTwo, blackVideoAssetTrack.timeRange.duration)
        videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, tempThree)
        
        // create Video composition layer
        let firstVideoCompositionLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack!)
        let secondVideoCompositionLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: secondVideoCompositionTrack!)
        
        firstVideoCompositionLayer.setTransform(firstTransform, at: kCMTimeZero)
        secondVideoCompositionLayer.setTransform(secondTransform, at: firstVideoAssetTrack.timeRange.duration)
        
        // Animation Opacity
        let endTime = CMTimeAdd(kCMTimeZero, firstVideoAsset.duration)
        let timeScale = firstVideoAsset.duration.timescale
        let durationAnimation = CMTime(seconds: 1, preferredTimescale: timeScale)
        let durationAnimationTimeRange = CMTimeRange(start: endTime, duration: durationAnimation)
        
        firstVideoCompositionLayer.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: durationAnimationTimeRange)
        
        let endTime2 = CMTimeAdd(firstVideoAsset.duration, secondVideoAsset.duration)
        let timeScale2 = secondVideoAsset.duration.timescale
        let durationAnimation2 = CMTime(seconds: 1, preferredTimescale: timeScale2)
        let durationAnimationTimeRange2 = CMTimeRange(start: endTime2, duration: durationAnimation2)
        
        secondVideoCompositionLayer.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: durationAnimationTimeRange2)
        
        videoCompositionInstruction.layerInstructions = [firstVideoCompositionLayer, secondVideoCompositionLayer]
       
        //Setting the Render Size and Frame Duration
        var firstNaturalSize: CGSize!
        var secondNaturalSize: CGSize!
        
        if firstVideoPortrait {
            firstNaturalSize = CGSize(width: firstVideoAssetTrack.naturalSize.height, height: firstVideoAssetTrack.naturalSize.width)
            secondNaturalSize = CGSize(width: secondVideoAssertTrack.naturalSize.height, height: secondVideoAssertTrack.naturalSize.width)
        } else {
            firstNaturalSize = firstVideoAssetTrack.naturalSize
            secondNaturalSize = secondVideoAssertTrack.naturalSize
        }
        
        var renderWidth: CGFloat!
        var renderHeight: CGFloat!
        
        
        
        if firstNaturalSize.width > secondNaturalSize.width {
            renderWidth = firstNaturalSize.width
        } else {
            renderWidth = secondNaturalSize.width
        }
        
        if firstNaturalSize.height > firstNaturalSize.height {
            renderHeight = firstNaturalSize.height
        } else {
            renderHeight = secondNaturalSize.height
        }
        
        // Exporting the Composition and Saving it to the Camera Roll
        let kDateFormatter = DateFormatter()
        kDateFormatter.dateStyle = .medium
        kDateFormatter.timeStyle = .short
        let date = Date()
        let dateString = kDateFormatter.string(from: date)
        
        // Export to file
        let path =  try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true).appendingPathComponent("\(dateString)").appendingPathExtension("mp4")
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(path)
        
        
        
        
        // Image with bgvideo
        let insertTime = CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration)
        
        
        // Create Image layer
        guard let image = UIImage(named: "n1") else { fatalError() }
        let outputSize = CGSize(width: renderWidth, height: renderHeight)
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(origin: CGPoint.zero, size: outputSize)
        imageLayer.contents = image.cgImage
        imageLayer.opacity = 0
        imageLayer.contentsGravity = kCAGravityResizeAspectFill
        
        setOrientation(image: image, onLayer: imageLayer, outputSize: outputSize)
        
        // Add Fade in & Fade out animation
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration = 1
        fadeInAnimation.fromValue = NSNumber(value: 0)
        fadeInAnimation.toValue = NSNumber(value: 1)
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = insertTime.seconds
        fadeInAnimation.fillMode = kCAFillModeForwards
        imageLayer.add(fadeInAnimation, forKey: "opacityIN")
        
        let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
        fadeOutAnimation.duration = 1
        fadeOutAnimation.fromValue = NSNumber(value: 1)
        fadeOutAnimation.toValue = NSNumber(value: 0)
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.beginTime = CMTimeAdd(insertTime, itemDuration).seconds
        fadeOutAnimation.fillMode = kCAFillModeForwards
        imageLayer.add(fadeOutAnimation, forKey: "opacityOUT")
        
        
       
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
        parentlayer.addSublayer(videoLayer)
        
        parentlayer.addSublayer(imageLayer)
        
        
        // Add Three Texts
        
        let firstTextData = TextInfos()
        firstTextData.text = "First Video"
        firstTextData.textColor = UIColor.white
        firstTextData.showTime = 1.0
        firstTextData.endTime = firstVideoAssetTrack.timeRange.duration.seconds
        firstTextData.textFrame = CGRect(x: 10, y: 10, width: 400, height: 300)
        
        let firstVideoText = makeTextLayers(string: firstTextData.text, fontSize: 50, textColor: firstTextData.textColor, frame:  firstTextData.textFrame, showTime:  firstTextData.showTime, hideTime:  firstTextData.endTime)
        
        
        
        let secondTextData = TextInfos()
        secondTextData.text = "Second Video"
        secondTextData.textColor = UIColor.white
        secondTextData.showTime = firstVideoAssetTrack.timeRange.duration.seconds// Second
        secondTextData.endTime =  insertTime.seconds
        secondTextData.textFrame = CGRect(x: 10, y: 10, width: 400, height: 300)

        let secondVideoText = makeTextLayers(string: secondTextData.text, fontSize: 50, textColor: secondTextData.textColor, frame:  secondTextData.textFrame, showTime:  secondTextData.showTime, hideTime:  secondTextData.endTime )
//
//
//
        let threeTextData = TextInfos()
        threeTextData.text = "Three Video"
        threeTextData.textColor = UIColor.white
        threeTextData.showTime = insertTime.seconds// Second
        threeTextData.endTime =  CMTimeAdd(insertTime, itemDuration).seconds
        threeTextData.textFrame = CGRect(x: 10, y: 10, width: 400, height: 300)

        let threeVideoText = makeTextLayers(string: threeTextData.text, fontSize: 50, textColor: threeTextData.textColor, frame:  threeTextData.textFrame, showTime:  threeTextData.showTime, hideTime:  threeTextData.endTime )
        
        
        parentlayer.addSublayer(firstVideoText)
        parentlayer.addSublayer(secondVideoText)
        parentlayer.addSublayer(threeVideoText)
        
       
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = [videoCompositionInstruction]
        mutableVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        mutableVideoComposition.frameDuration = CMTimeMake(1,30)
        
         mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentlayer)
       
        let exporter = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = path
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mutableVideoComposition
       
        
        exporter?.exportAsynchronously(completionHandler: {
            
            switch exporter!.status {
            case .completed:
                print("url \(path)")
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
                    }) { saved, error in
                        if saved {
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            case .failed:
                print("error failed")
                
            case .exporting:
                print("exporting")
                
            case .cancelled:
                print("cancelled")
                
            case .waiting:
                print("waiting")
                
            default:
                print("unknow error")
            }
            
            
        })
        
        
    }
    
    
    
    func setOrientation(image:UIImage?, onLayer:CALayer, outputSize:CGSize) -> Void {
        guard let image = image else { return }
        
        if image.imageOrientation == UIImageOrientation.up {
            // Do nothing
        }
        else if image.imageOrientation == UIImageOrientation.left {
            let rotate = CGAffineTransform(rotationAngle: .pi/2)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImageOrientation.down {
            let rotate = CGAffineTransform(rotationAngle: .pi)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImageOrientation.right {
            let rotate = CGAffineTransform(rotationAngle: -.pi/2)
            onLayer.setAffineTransform(rotate)
        }
    }
}

