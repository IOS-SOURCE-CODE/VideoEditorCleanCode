//
//  MergeVideoInfo.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit

protocol MergeVideoInfo {
  
    var index:Int { get }
    var image:UIImage?  { get }
    var asset:AVAsset?  { get }
    var isVideo : Bool  { get }
    
}


protocol TextInfo {
    var text: String { get }
    var fontSize:CGFloat  { get }
    var textColor: String { get }
    var showTime:CGFloat  { get }
    var endTime:CGFloat { get }
    var textFrame: CGRect { get }
}


protocol SpiltVideoInfo {
    
}
