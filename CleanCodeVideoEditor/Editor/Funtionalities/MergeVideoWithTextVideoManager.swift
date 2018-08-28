//
//  MergeVideoWithTextVideoManager.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVKit


class MergeVideoWithTextVideoManager : OutputVideoManagable, VideoCompositionInstruction, MakeTextLayerable {
    
    let defaultSize = CGSize(width: 1920, height: 1080) // Default video size
    var imageDuration = 5.0 // Duration of each image
    
    func makeVideoFrom(data:[MergeVideoInfo], textData:[TextInfo]?, completion:@escaping VideoManagerCompletion) -> Void {

        var outputSize = CGSize.init(width: 0, height: 0)
        var insertTime = kCMTimeZero
        var arrayLayerInstructions:[AVMutableVideoCompositionLayerInstruction] = []
        var arrayLayerImages:[CALayer] = []

        // Black background video
        guard let bgVideoURL = Bundle.main.url(forResource: "black", withExtension: "mov") else {
            print("Need black background video !")
            completion(nil,nil)
            return
        }

        let bgVideoAsset = AVAsset(url: bgVideoURL)
        let bgVideoTrack = bgVideoAsset.tracks(withMediaType: AVMediaType.video).first

        // Silence sound (in case of video has no sound track)
        let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")
        let silenceAsset = AVAsset(url:silenceURL!)
        let silenceSoundTrack = silenceAsset.tracks(withMediaType: AVMediaType.audio).first

        // Init composition
        let mixComposition = AVMutableComposition.init()

        // Determine video output
        for videoData in data {

            guard let videoAsset = videoData.asset else { continue }

            // Get video track
            guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }

            let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)

            var videoSize = videoTrack.naturalSize
            if assetInfo.isPortrait == true {
                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }

            if videoSize.height > outputSize.height {
                outputSize = videoSize
            }
        }

        if outputSize.width == 0 || outputSize.height == 0 {
            outputSize = defaultSize
        }

        // Merge
        for videoData in data {
            if videoData.isVideo {

                guard let videoAsset = videoData.asset else { continue }

                // Get video track
                guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }

                // Get audio track
                var audioTrack:AVAssetTrack?
                if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
                    audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
                }
                else {
                    audioTrack = silenceSoundTrack
                }

                // Init video & audio composition track
                let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

                let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

                do {
                    let startTime = kCMTimeZero
                    let duration = videoAsset.duration

                    // Add video track to video composition at specific time
                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(startTime, duration),
                                                               of: videoTrack,
                                                               at: insertTime)

                    // Add audio track to audio composition at specific time
                    if let audioTrack = audioTrack {
                        try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(startTime, duration),
                                                                   of: audioTrack,
                                                                   at: insertTime)
                    }

                    // Add instruction for video track
                    let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack!,
                                                                               asset: videoAsset,
                                                                               standardSize: outputSize,
                                                                               atTime: insertTime)

                    // Hide video track before changing to new track
                    let endTime = CMTimeAdd(insertTime, duration)
                    let timeScale = videoAsset.duration.timescale
                    let durationAnimation = CMTime.init(seconds: 1, preferredTimescale: timeScale)

                    layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange.init(start: endTime, duration: durationAnimation))

                    arrayLayerInstructions.append(layerInstruction)

                    // Increase the insert time
                    insertTime = CMTimeAdd(insertTime, duration)
                }
                catch {
                    print("Load track error")
                }
            }
            else { // Image
                let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

                let itemDuration = CMTime.init(seconds:imageDuration, preferredTimescale: bgVideoAsset.duration.timescale)

                do {
                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, itemDuration),
                                                               of: bgVideoTrack!,
                                                               at: insertTime)
                }
                catch {
                    print("Load background track error")
                }

                // Create Image layer
                guard let image = videoData.image else { continue }

                let imageLayer = CALayer()
                imageLayer.frame = CGRect.init(origin: CGPoint.zero, size: outputSize)
                imageLayer.contents = image.cgImage
                imageLayer.opacity = 0
                imageLayer.contentsGravity = kCAGravityResizeAspectFill

                setOrientation(image: image, onLayer: imageLayer, outputSize: outputSize)

                // Add Fade in & Fade out animation
                let fadeInAnimation = CABasicAnimation.init(keyPath: "opacity")
                fadeInAnimation.duration = 1
                fadeInAnimation.fromValue = NSNumber(value: 0)
                fadeInAnimation.toValue = NSNumber(value: 1)
                fadeInAnimation.isRemovedOnCompletion = false
                fadeInAnimation.beginTime = insertTime.seconds == 0 ? 0.05: insertTime.seconds
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

                arrayLayerImages.append(imageLayer)

                // Increase the insert time
                insertTime = CMTimeAdd(insertTime, itemDuration)
            }
        }

        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions

        // Init Video layer
        let videoLayer = CALayer()
        videoLayer.frame = CGRect.init(x: 0, y: 0, width: outputSize.width, height: outputSize.height)

        let parentlayer = CALayer()
        parentlayer.frame = CGRect.init(x: 0, y: 0, width: outputSize.width, height: outputSize.height)

        parentlayer.addSublayer(videoLayer)

        // Add Image layers
        for layer in arrayLayerImages {
            parentlayer.addSublayer(layer)
        }

        // Add Text layer
        if let textData = textData {
            for aTextData in textData {
                let textLayer = makeTextLayer(string: aTextData.text, fontSize: aTextData.fontSize, textColor: aTextData.textColor, frame: aTextData.textFrame, showTime: aTextData.showTime, hideTime: aTextData.endTime)

                parentlayer.addSublayer(textLayer)
            }
        }


        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = outputSize
        mainComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentlayer)

        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideoImageText.mp4")
        let exportURL = URL.init(fileURLWithPath: path)

        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)

        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainComposition

        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter: exporter, videoURL: exportURL, completion: completion)
            }
        })



    }
    
}

