//
//  VideoData.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit

protocol MergeVideoInfo {
    var index:Int { get }
    var image:UIImage { get }
    var asset:AVAsset { get }
    var isVideo: Bool { get }
}


