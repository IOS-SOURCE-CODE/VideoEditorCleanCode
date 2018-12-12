//
//  MergeVideoInfo.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit

class MergeVideoInfo: NSObject {
  
    var index:Int?
    var image:UIImage?
    var asset:AVAsset?
    var isVideo = false
    
}


class TextInfo : NSObject {
    
    var text: String!
    var fontSize:CGFloat = 50
    var textColor = UIColor.white
    var showTime:CGFloat = 0
    var endTime:CGFloat = 0
    var textFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
}

class TextInfos : NSObject {
    
    var text: String!
    var fontSize:CGFloat = 50
    var textColor = UIColor.white
    var showTime:Double = 0
    var endTime:Double = 0
    var textFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
}
