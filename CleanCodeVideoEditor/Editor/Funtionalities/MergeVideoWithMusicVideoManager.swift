//
//  MergeVideoWithMusicVideoManager.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVKit

class MergeVideoWithMusic:  OutputVideoManagable, VideoCompositionInstruction  {
    
    func merge(video:AVAsset, withBackgroundMusic music:AVAsset, completion:@escaping VideoManagerCompletion) -> Void {
        // Init composition
        let mixComposition = AVMutableComposition.init()
        
        // Get video track
        guard let videoTrack = video.tracks(withMediaType: AVMediaType.video).first else {
            completion(nil, nil)
            return
        }
        
        let outputSize = videoTrack.naturalSize
        let insertTime = kCMTimeZero
        
        // Get audio track
        var audioTrack:AVAssetTrack?
        if music.tracks(withMediaType: AVMediaType.audio).count > 0 {
            audioTrack = music.tracks(withMediaType: AVMediaType.audio).first
        }
        
        // Init video & audio composition track
        let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        let startTime = kCMTimeZero
        let duration = video.duration
        
        do {
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
        }
        catch {
            print("Load track error")
        }
        
        // Init layer instruction
        let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack!,
                                                                   asset: video,
                                                                   standardSize: outputSize,
                                                                   atTime: insertTime)
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideoWithMusic.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        exportMergeVideo(insertTime: insertTime, outputComposition: mixComposition, exportURL: exportURL, outSize: outputSize, arrayLayerInstruction: [layerInstruction], completion:completion )
        
    }
}
