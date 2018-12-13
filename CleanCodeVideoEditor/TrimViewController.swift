//
//  TrimViewController.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 13/12/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVFoundation

typealias TrimCompletion = (AVAssetExportSession.Status?, Error?) -> ()

typealias TrimPoints = [(CMTime, CMTime)]

class TrimViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVideoUrl = Bundle.main.url(forResource: "movie1", withExtension: "mov")!
        let firstVideoAsset = AVAsset(url: firstVideoUrl)
        
        // Exporting the Composition and Saving it to the Camera Roll
        let kDateFormatter = DateFormatter()
        kDateFormatter.dateStyle = .medium
        kDateFormatter.timeStyle = .short
        let date = Date()
        let dateString = kDateFormatter.string(from: date)
        
        // Export to file
        let path =  try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true).appendingPathComponent("\(dateString)").appendingPathExtension("mp4")
        
        let timeScale: Int32 = 1000
        
        let trimPoints = [(CMTimeMake(2000, timeScale),CMTimeMake(9000, timeScale))]
        
        trimVideo(sourceURL: firstVideoUrl, destinationURL: path, trimPoints: trimPoints) { (status, error) in
            print("path \(path)")
            print("status == \(status?.rawValue) error = \(error?.localizedDescription)")
        }
        
    }
    
    func trimVideo(sourceURL: URL, destinationURL: URL, trimPoints: TrimPoints, completion: TrimCompletion?) {
      
        
        let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetPassthrough
        
        if verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first!
            let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first!
            var compError: Error?
            
            var accumulatedTime = kCMTimeZero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(startTimeForCurrentSlice, durationOfCurrentSlice)
                
                do {
                    try videoCompTrack?.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                    try audioCompTrack?.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                    
                } catch(let error) {
                    compError = error
                }
                
                if compError != nil {
                    NSLog("error during composition: \(String(describing: compError))")
                    if let completion = completion {
                        completion(.failed, compError)
                    }
                }
                
                accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
            }
            
            let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset)
            exportSession?.outputURL = destinationURL
            exportSession?.outputFileType = .m4v
            exportSession?.shouldOptimizeForNetworkUse = true
    
            
            exportSession?.exportAsynchronously(completionHandler: {
                if let completion = completion {
                    completion(exportSession?.status, exportSession?.error)
                }
            })
        } else {
            NSLog("Could not find a suitable export preset for the input video")
            
            let error = NSError(domain: "org.linuxguy.VideoLab", code: -1, userInfo: nil) as Error
            if let completion = completion {
                completion(AVAssetExportSession.Status.failed, error)
            }
        }
    }
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    
}
