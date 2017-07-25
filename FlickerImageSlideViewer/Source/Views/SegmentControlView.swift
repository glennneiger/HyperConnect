//
//  SegmentControlView.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

class SegmentControlItem: NSObject {
}

class SegmentControlView: UIView {
//    weak open var delegate: SegmentControlViewDelegate?
    
    private let segmentViews: [UIButton] = [UIButton]()
    init(items: [SegmentControlItem]) {
        super.init(frame: .zero)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
