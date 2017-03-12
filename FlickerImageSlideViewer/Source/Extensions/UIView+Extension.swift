//
//  UIView+Extension.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func applyMarginConstraint(inset: UIEdgeInsets) {
        guard let superview = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": self]
        let metrics = ["left": inset.left,
                       "right": inset.right,
                       "top": inset.top,
                       "bottom": inset.bottom]
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[view]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[view]-bottom-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        superview.addConstraints(constraints)
    }
}
