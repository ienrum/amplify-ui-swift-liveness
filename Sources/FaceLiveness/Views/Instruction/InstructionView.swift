//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// 도면의 「상태 안내」 말풍선. 어떤 문구를 언제 띄울지는 SDK 의 상태가 정한다 —
/// 여기서는 색만 받는다.
struct InstructionView: View {
    let text: String
    let backgroundColor: Color
    var textColor: Color = .white
    var font: Font = KTalkCaptureStyle.bubbleLabel

    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .font(font)
            .multilineTextAlignment(.center)
            .padding(.horizontal, KTalkCaptureStyle.bubblePadHorizontal)
            .padding(.vertical, KTalkCaptureStyle.bubblePadVertical)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}
