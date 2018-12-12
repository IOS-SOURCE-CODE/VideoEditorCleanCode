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

extension TestViewController {
    func implmentWholeProcessStep2() {
        
        // Create composition and video track, audio track in to composition
        let mutableComposition = AVMutableComposition()
        let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let secondVideoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // Load video asset
        let firstVideoUrl = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let firstVideoAsset = AVAsset(url: firstVideoUrl!)
        
        let secondVideoUrl = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        let secondVideoAsset = AVAsset(url: secondVideoUrl!)
        
        // load track from video asset
        let firstVideoAssetTrack = firstVideoAsset.tracks(withMediaType: .video).first!
        let secondVideoAssertTrack = secondVideoAsset.tracks(withMediaType: .video).first!
        
        // Add loaded track from video asset to video composition track
        let firstVideoTimeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
        let secondVideoTimeRange = CMTimeRangeMake(kCMTimeZero,secondVideoAssertTrack.timeRange.duration)
        try! videoCompositionTrack?.insertTimeRange(firstVideoTimeRange, of: firstVideoAssetTrack, at: kCMTimeZero)
        try! secondVideoCompositionTrack?.insertTimeRange(secondVideoTimeRange, of: secondVideoAssertTrack, at: firstVideoAssetTrack.timeRange.duration)
        
        // Load audio
        let urlMusic = Bundle.main.url(forResource: "creativeminds", withExtension: "mp3")
        let musicAsset = AVAsset(url: urlMusic!)
        
        // Get auido track
        let musicTrack = musicAsset.tracks(withMediaType: .audio).first!
        let audioDuration = CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration)
        let musicTimeRange = CMTimeRangeMake(kCMTimeZero, audioDuration)
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
        videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration))
        
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
        
        
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = [videoCompositionInstruction]
        mutableVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        mutableVideoComposition.frameDuration = CMTimeMake(1,30)
       
        let exporter = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = path
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mutableVideoComposition
       
        
        exporter?.exportAsynchronously(completionHandler: {
            if exporter?.status == AVAssetExportSessionStatus.completed {
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
                
            }
        })
        
        
    }
}
