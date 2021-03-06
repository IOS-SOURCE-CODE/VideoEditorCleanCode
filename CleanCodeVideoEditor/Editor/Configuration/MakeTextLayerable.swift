//
//  MakeTextLayerable.swift
//  CleanCodeVideoEditor
//
//  Created by seyha on 27/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit


protocol MakeTextLayerable {
    
    func makeTextLayer(string:String, fontSize:CGFloat, textColor:UIColor, frame:CGRect, showTime:CGFloat, hideTime:CGFloat) -> CXETextLayer
}


extension MakeTextLayerable {
    
    func makeTextLayer(string:String, fontSize:CGFloat, textColor:UIColor, frame:CGRect, showTime:CGFloat, hideTime:CGFloat) -> CXETextLayer {
        
        let textLayer = CXETextLayer()
        textLayer.string = string
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = textColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.opacity = 0
        textLayer.frame = frame
        textLayer.display()
        
        
        let fadeInAnimation = CABasicAnimation.init(keyPath: "opacity")
        fadeInAnimation.duration = 1
        fadeInAnimation.fromValue = NSNumber(value: 0)
        fadeInAnimation.toValue = NSNumber(value: 1)
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = CFTimeInterval(showTime)
        fadeInAnimation.fillMode = kCAFillModeForwards
        
        textLayer.add(fadeInAnimation, forKey: "textOpacityIN")
        
        if hideTime > 0 {
            let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
            fadeOutAnimation.duration = 1
            fadeOutAnimation.fromValue = NSNumber(value: 1)
            fadeOutAnimation.toValue = NSNumber(value: 0)
            fadeOutAnimation.isRemovedOnCompletion = false
            fadeOutAnimation.beginTime = CFTimeInterval(hideTime)
            fadeOutAnimation.fillMode = kCAFillModeForwards
            
            textLayer.add(fadeOutAnimation, forKey: "textOpacityOUT")
        }
        
        return textLayer
    }
    
    func makeTextLayers(string:String, fontSize:CGFloat, textColor:UIColor, frame:CGRect, showTime:Double, hideTime:Double) -> CXETextLayer {
        
        let textLayer = CXETextLayer()
        textLayer.string = string
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = textColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.opacity = 0
        textLayer.frame = frame
        textLayer.display()
        
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration = 1
        fadeInAnimation.fromValue = NSNumber(value: 0)
        fadeInAnimation.toValue = NSNumber(value: 1)
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = showTime
        fadeInAnimation.fillMode = kCAFillModeForwards
        textLayer.add(fadeInAnimation, forKey: "opacityIN")
        
        let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
        fadeOutAnimation.duration = 1
        fadeOutAnimation.fromValue = NSNumber(value: 1)
        fadeOutAnimation.toValue = NSNumber(value: 0)
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.beginTime = hideTime
        fadeOutAnimation.fillMode = kCAFillModeForwards
        textLayer.add(fadeOutAnimation, forKey: "opacityOUT")
        
        
//
//        let fadeInAnimation = CABasicAnimation.init(keyPath: "opacity")
//        fadeInAnimation.duration = 1
//        fadeInAnimation.fromValue = NSNumber(value: 0)
//        fadeInAnimation.toValue = NSNumber(value: 1)
//        fadeInAnimation.isRemovedOnCompletion = false
////        fadeInAnimation.beginTime = CFTimeInterval(showTime)
//        fadeInAnimation.beginTime = CACurrentMediaTime() + showTime
//        fadeInAnimation.fillMode = kCAFillModeForwards
//
//        textLayer.add(fadeInAnimation, forKey: "textOpacityIN")
        
//        if hideTime > 0 {
//            let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
//            fadeOutAnimation.duration = 1
//            fadeOutAnimation.fromValue = NSNumber(value: 1)
//            fadeOutAnimation.toValue = NSNumber(value: 0)
//            fadeOutAnimation.isRemovedOnCompletion = false
////            fadeOutAnimation.beginTime = CFTimeInterval(hideTime)
//              fadeOutAnimation.beginTime = CACurrentMediaTime() + hideTime
//            fadeOutAnimation.fillMode = kCAFillModeForwards
//
//            textLayer.add(fadeOutAnimation, forKey: "textOpacityOUT")
//        }
        
        return textLayer
    }
}
