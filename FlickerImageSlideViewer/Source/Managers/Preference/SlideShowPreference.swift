//
//  SlideShowPreference.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

enum SlideShowAnimation: Int {
    case CurveEaseIn
    case CurveEaseOut
    case CurlUp
    case CurlDown
    case FlipLeft
}

final class SlideShowPreference {
    static let sharedManager = SlideShowPreference()
    
    var slideShowInterval: Int = 4
    private var slideShowAnimations: [SlideShowAnimation] = [SlideShowAnimation]()
    
    func randomEffect() -> UIViewAnimationOptions? {
        if slideShowAnimations.count > 0 {
            return viewAnimationOption(withSlideShowAnimation: slideShowAnimations[Int(arc4random_uniform(UInt32(slideShowAnimations.count)))])
        }
        
        return nil
    }
    
    func appendSlideShowAnimation(animation: SlideShowAnimation) {
        if slideShowAnimations.contains(animation) == false {
            slideShowAnimations.append(animation)
        }
    }
    
    func removeSlideShowAnimation(animation: SlideShowAnimation) {
        if let index = slideShowAnimations.index(of: animation) {
            slideShowAnimations.remove(at: index)
        }
    }
    
    private func viewAnimationOption(withSlideShowAnimation: SlideShowAnimation) -> UIViewAnimationOptions? {
        var viewAnimationOption: UIViewAnimationOptions? = nil
        switch withSlideShowAnimation {
        case .CurveEaseIn:
            viewAnimationOption = .curveEaseIn
        case .CurveEaseOut:
            viewAnimationOption = .curveEaseOut
        case .CurlUp:
            viewAnimationOption = .transitionCurlUp
        case .CurlDown:
            viewAnimationOption = .transitionCurlDown
        case .FlipLeft:
            viewAnimationOption = .transitionFlipFromLeft
        }
        
        return viewAnimationOption
    }
}
