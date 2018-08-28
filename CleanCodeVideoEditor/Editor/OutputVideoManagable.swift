//
//  OutputVideoManagable.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVKit



protocol OutputVideoManagable  {
    
    func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping VideoManagerCompletion) -> Void
    
    func exportMergeVideo(insertTime:CMTime, outputComposition: AVMutableComposition, exportURL: URL, outSize: CGSize,arrayLayerInstruction: [AVMutableVideoCompositionLayerInstruction], completion: @escaping VideoManagerCompletion)
}


extension OutputVideoManagable {
    
    
    func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping VideoManagerCompletion) -> Void {
        
        if exporter?.status == AVAssetExportSessionStatus.completed {
            print("Exported file: \(videoURL.absoluteString)")
            completion(videoURL,nil)
        }
        else if exporter?.status == AVAssetExportSessionStatus.failed {
            completion(videoURL,exporter?.error)
        }
    }
    
    
    func exportMergeVideo(insertTime:CMTime, outputComposition: AVMutableComposition, exportURL: URL, outSize: CGSize,arrayLayerInstruction: [AVMutableVideoCompositionLayerInstruction], completion: @escaping VideoManagerCompletion) {
        
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertTime)
        mainInstruction.layerInstructions = arrayLayerInstruction
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = outSize
        
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: outputComposition, presetName: AVAssetExportPresetHighestQuality)
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
