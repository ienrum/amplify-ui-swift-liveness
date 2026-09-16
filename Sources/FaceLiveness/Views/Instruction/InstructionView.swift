//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct InstructionView: View {
    let text: String
    let backgroundColor: Color
    var textColor: Color = KTalkCaptureStyle.titleColor
    var font: Font = KTalkCaptureStyle.description
    
    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .font(font)
            .multilineTextAlignment(.center)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}
