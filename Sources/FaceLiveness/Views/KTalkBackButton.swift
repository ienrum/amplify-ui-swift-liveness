//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// The app back control; capture keeps the SDK's existing cancellation action.
struct KTalkBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BackChevron()
                .stroke(
                    KTalkCaptureStyle.backIconColor,
                    style: StrokeStyle(
                        lineWidth: KTalkCaptureStyle.backIconLineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(
                    width: KTalkCaptureStyle.backIconSize,
                    height: KTalkCaptureStyle.backIconSize
                )
                .padding(.leading, KTalkCaptureStyle.sideMargin)
                .frame(
                    width: KTalkCaptureStyle.backButtonWidth,
                    height: KTalkCaptureStyle.navBarHeight,
                    alignment: .leading
                )
                .background(Color.white)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(
            Text("amplify_ui_liveness_challenge_a11y_back_content_description".localized())
        )
    }
}

/// KTalk fork: the app's own back chevron (assets/icons/arrow/24-chevron-left.svg).
private struct BackChevron: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / 24
        var path = Path()
        path.move(to: CGPoint(x: 15 * scale, y: 4.5 * scale))
        path.addLine(to: CGPoint(x: 7.5 * scale, y: 12 * scale))
        path.addLine(to: CGPoint(x: 15 * scale, y: 19.5 * scale))
        return path
    }
}
