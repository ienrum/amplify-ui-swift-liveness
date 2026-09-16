//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

class OvalView: UIView {
    let ovalFrame: CGRect

    init(frame: CGRect, ovalFrame: CGRect) {
        self.ovalFrame = ovalFrame
        super.init(frame: frame)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let mask = UIBezierPath(rect: bounds)
        let oval = UIBezierPath(ovalIn: ovalFrame)
        mask.append(oval.reversing())

        // KTalk fork: 도면의 「어둡게 덮기」. 타원 좌표와 크기는 SDK 값 그대로다.
        KTalkCaptureStyle.captureScrim.setFill()
        mask.fill()

        UIColor.clear.setFill()
        KTalkCaptureStyle.captureOvalStroke.setStroke()
        oval.lineWidth = KTalkCaptureStyle.captureOvalStrokeWidth
        oval.stroke()
    }

    required init?(coder: NSCoder) { nil }
}
