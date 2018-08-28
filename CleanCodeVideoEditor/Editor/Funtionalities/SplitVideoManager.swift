//
//  SplitVideoManager.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVKit

typealias SplitVideoManagerCompletion = (_ status: AVAssetExportSessionStatus, _ outputURL: URL) -> Void


protocol SplitVideoManagerType {
     func splitVideoByStartAndEndTime(videoAsset: MergeVideoInfo,startTime: Double, endTime: Double, outputURL: URL, completion: @escaping SplitVideoManagerCompletion)
}

class SplitVideoManager : SplitVideoManagerType {
    
  
    func splitVideoByStartAndEndTime(videoAsset: MergeVideoInfo,startTime: Double = 0, endTime: Double, outputURL: URL, completion: @escaping SplitVideoManagerCompletion) {
       
        guard let duration = videoAsset.asset?.duration else { return }
        
        let length =  CMTime(seconds: duration.seconds, preferredTimescale: duration.timescale)
        
        
        FileManager.default.removeItemIfExisted(outputURL)
        
        
        if let exportSession = AVAssetExportSession(asset: videoAsset.asset!, presetName: AVAssetExportPresetHighestQuality) {
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            let startCMTime = CMTime(seconds: startTime, preferredTimescale: duration.timescale)
            var endCMTime = CMTime(seconds: endTime, preferredTimescale: duration.timescale)
            
            if endCMTime > length {
                endCMTime = length
            }
            
            let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)
            
            exportSession.timeRange = timeRange
            
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    completion(exportSession.status, outputURL)
                }
            })
            
        }
    }
    
}
