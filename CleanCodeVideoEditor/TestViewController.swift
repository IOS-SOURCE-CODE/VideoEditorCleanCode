//
//  TestViewController.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 6/12/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class TestViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func implmentWholeProcessStep1() {
        
        // Create composition and video track, audio track in to composition
        let mutableComposition = AVMutableComposition()
        let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
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
        let secondVideoTimeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
        try! videoCompositionTrack?.insertTimeRange(firstVideoTimeRange, of: firstVideoAssetTrack, at: kCMTimeZero)
        try! videoCompositionTrack?.insertTimeRange(secondVideoTimeRange, of: secondVideoAssertTrack, at: firstVideoAssetTrack.timeRange.duration)
        
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
        let firstVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
        
        
        let secondVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssertTrack.timeRange.duration))
        
        // create Video composition layer
        let firstVideoCompositionLayer = AVMutableVideoCompositionLayerInstruction()
        firstVideoCompositionInstruction.layerInstructions = [firstVideoCompositionLayer]
        
        let secondVideoCompositionLayer = AVMutableVideoCompositionLayerInstruction()
        secondVideoCompositionInstruction.layerInstructions = [secondVideoCompositionLayer]
        
        
        firstVideoCompositionLayer.setTransform(firstTransform, at: kCMTimeZero)
        secondVideoCompositionLayer.setTransform(secondTransform, at: firstVideoAssetTrack.timeRange.duration)
        
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = [firstVideoCompositionInstruction, secondVideoCompositionInstruction]
        
        
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
        
        mutableVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        mutableVideoComposition.frameDuration = CMTimeMake(30,1)
        
        
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
        
        let exporter = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = path
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mutableVideoComposition
        
        exporter?.exportAsynchronously(completionHandler: {
            if exporter?.status == AVAssetExportSessionStatus.completed {
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
        })
        
        
    }
    
    
    func InCorperating_Core_Animation() {
        let waterMark = CALayer()
        waterMark.backgroundColor = UIColor.red.cgColor
    }
    
    func step() {
        
        // Create Composition
        let mutableComposition = AVMutableComposition()
        
        // create video track
        let mutableCompositionVideoTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        // create audio track
        let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // Load video asset
        let videoUrl = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let videoAsset = AVAsset(url: videoUrl!)
        
        let anotherVideoUrl = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        let anotherVideoAsset = AVAsset(url: anotherVideoUrl!)
        
        // Get track from video
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first!
        let anotherVideoTrack = anotherVideoAsset.tracks(withMediaType: AVMediaType.video).first!
        
        let videoTrackTimeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
        let anotherVideoTrackTimeRange = CMTimeRangeMake(kCMTimeZero, anotherVideoTrack.timeRange.duration)
        
        try! mutableCompositionVideoTrack?.insertTimeRange(videoTrackTimeRange, of: videoTrack, at: kCMTimeZero)
        try! mutableCompositionVideoTrack?.insertTimeRange(anotherVideoTrackTimeRange, of: anotherVideoTrack, at: videoTrack.timeRange.duration)
        
        
        // Create audioMix
        let mutableAudioMix = AVMutableAudioMix()
        let mixParamters = AVMutableAudioMixInputParameters()
        let audioTimeRange = CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)
        mixParamters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0, timeRange:audioTimeRange)
        mutableAudioMix.inputParameters = [mixParamters]
        
        
        // Create changable compositon by using videocompositioninstruction
        let mutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mutableVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)
        mutableVideoCompositionInstruction.backgroundColor = UIColor.red.cgColor
        
        
        // Apply Opacity Ramp by using video compositionlayerinstruction
        // Get track from video
        let firstVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        firstVideoCompositionInstruction.timeRange = videoTrackTimeRange
        
        
        
        let secondVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        let addTwoVideoCMTime = CMTimeAdd(videoTrack.timeRange.duration, anotherVideoTrack.timeRange.duration)
        secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(videoTrack.timeRange.duration, addTwoVideoCMTime)
        
        //create layer
        let firstVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        firstVideoLayerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: videoTrackTimeRange)
        
        let secondVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        
        // add to layer instruction to composition instruction
        firstVideoCompositionInstruction.layerInstructions = [firstVideoLayerInstruction]
        secondVideoCompositionInstruction.layerInstructions = [secondVideoLayerInstruction]
        
        // Fake video composition
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = [firstVideoCompositionInstruction, secondVideoCompositionInstruction]
        
        
        
    }
    
    
    
    
    
}
