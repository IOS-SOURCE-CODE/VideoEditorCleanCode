//
//  AvAudioMixManager.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 4/12/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVFoundation

struct AVAudioMixManager {
    
    static func customMixAudio(asset: AVAsset) -> AVPlayer? {
        
        let playerItem = AVPlayerItem(asset: asset)
        
        let fadeTime: CMTime = CMTimeMake(15,1)
        let fadeInStartTime: CMTime = kCMTimeZero
        let fadeOutStartTime: CMTime = CMTimeSubtract(asset.duration, fadeTime)
        
        
        let fadeInRange: CMTimeRange = CMTimeRange(start: fadeInStartTime, duration: fadeTime)
        let fadeOutRange: CMTimeRange = CMTimeRange(start: fadeOutStartTime, duration: fadeTime)
        
        guard let audioTrack =  asset.tracks(withMediaType: AVMediaType.audio).first else { return nil }
        
        let paramaters: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)
        paramaters.trackID = audioTrack.trackID
        paramaters.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0, timeRange: fadeInRange)
        paramaters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0, timeRange: fadeOutRange)
        
        let audioMix = AVMutableAudioMix()
    
        audioMix.inputParameters = [paramaters]
        playerItem.audioMix = audioMix
        
      
        let player =  AVPlayer(playerItem: playerItem)
       return player
        
    }
    
    static func cusomRamValueMixAudio(asset: AVAsset) {
        
        
        let fadeTime: CMTime = CMTimeMake(25,1)
        let fadeInStartTime: CMTime = kCMTimeZero
        let fadeOutStartTime: CMTime = CMTimeSubtract(asset.duration, fadeTime)
        
        
        let fadeInRange: CMTimeRange = CMTimeRange(start: fadeInStartTime, duration: fadeTime)
        let fadeOutRange: CMTimeRange = CMTimeRange(start: fadeOutStartTime, duration: fadeTime)
        
        guard let audioTrack =  asset.tracks(withMediaType: AVMediaType.audio).first else { return  }
        
        let paramaters: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)
        paramaters.trackID = audioTrack.trackID
        paramaters.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0, timeRange: fadeInRange)
        paramaters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0, timeRange: fadeOutRange)
        
        let audioMix = AVMutableAudioMix()
        
        audioMix.inputParameters = [paramaters]
        
        // Export to file
        
        let path = NSTemporaryDirectory().appending("rampaudioMix.m4a")
        let exportURL = URL.init(fileURLWithPath: path)
        
        FileManager.default.removeItemIfExisted(exportURL)
        
        // TrimTime
        
//        let startTrimTime:CMTime = CMTimeMakeWithSeconds(0, 1)
//        let endTrimTime:CMTime = CMTimeMakeWithSeconds(5, 1);
//        let exportTimeRange: CMTimeRange = CMTimeRangeFromTimeToTime(startTrimTime, endTrimTime)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality)
        exportSession?.outputURL = exportURL
        exportSession?.audioMix = audioMix
        exportSession?.outputFileType = .mp4
        exportSession?.timeRange = audioTrack.timeRange
        
        exportSession?.exportAsynchronously(completionHandler: {
            print("export session status \(exportSession?.status.rawValue)")
            print("export url \(exportURL)")
        })
        
    }
    
  
}
