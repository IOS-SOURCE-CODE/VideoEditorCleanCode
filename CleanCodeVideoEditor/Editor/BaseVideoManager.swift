//
//  BaseVideoManager.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation
import AVFoundation

typealias VideoManagerCompletion = (URL?, Error?) -> Void

class BaseVideoManager {
    
    let splitVideoManager = SplitVideoManager()
    let mergeVideoToVideoManager = MergeVideoToVideoManager()
    let mergeVideoWithTextVideoManager = MergeVideoWithTextVideoManager()
    let mergeVideoWithMusicVideoManager = MergeVideoWithMusicVideoManager()

}


extension BaseVideoManager: SplitVideoManagerType {
    func splitVideoByStartAndEndTime(videoAsset: MergeVideoInfo, startTime: Double, endTime: Double, outputURL: URL, completion: @escaping SplitVideoManagerCompletion) {
        splitVideoManager.splitVideoByStartAndEndTime(videoAsset: videoAsset, endTime: endTime, outputURL: outputURL, completion: completion)
    }
}

extension BaseVideoManager: MergeVideoToVideoManagerType {
    func merge(arrayVideos: [AVAsset], animation: Bool, completion: @escaping VideoManagerCompletion) {
        mergeVideoToVideoManager.merge(arrayVideos: arrayVideos, animation: animation, completion: completion)
    }
}

extension BaseVideoManager: MergeVideoWithTextVideoManagerType {
    func merge(data: [MergeVideoInfo], textData: [TextInfo]?, completion: @escaping VideoManagerCompletion) {
    mergeVideoWithTextVideoManager.merge(data: data, textData: textData, completion: completion)
        
    }
}

extension BaseVideoManager : MergeVideoWithMusicVideoManagerType{
    func merge(video: AVAsset, withBackgroundMusic music: AVAsset, completion: @escaping VideoManagerCompletion) {
         mergeVideoWithMusicVideoManager.merge(video: video, withBackgroundMusic: music, completion: completion)
    }
}
