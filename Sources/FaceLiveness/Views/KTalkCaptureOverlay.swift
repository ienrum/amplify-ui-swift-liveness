//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/*
 KTalk fork: 촬영 중 화면의 겉모습(DSN-APP-IDT-0007-06).

 여기 있는 것은 표시뿐이다. 타원 좌표와 얼굴 판정, 색광의 순서·시간은 모두 SDK 가
 정한 값을 그대로 읽어 그린다.
 */

/// 도면의 「녹화 표시」.
struct KTalkRecordingBadge: View {
    var body: some View {
        HStack(spacing: KTalkCaptureStyle.recordingGap) {
            Circle()
                .fill(KTalkCaptureStyle.recordingDotColor)
                .frame(
                    width: KTalkCaptureStyle.recordingDotSize,
                    height: KTalkCaptureStyle.recordingDotSize
                )
            Text(LocalizedStrings.challenge_recording_indicator_label)
                .font(KTalkCaptureStyle.recordingLabel)
                .foregroundColor(.white)
        }
        .padding(.leading, KTalkCaptureStyle.recordingPadLeading)
        .padding(.trailing, KTalkCaptureStyle.recordingPadTrailing)
        .padding(.vertical, KTalkCaptureStyle.recordingPadVertical)
        .background(KTalkCaptureStyle.capturePill)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }
}

/// 도면의 「취소」. 동작은 촬영 화면이 쓰던 사용자 취소 그대로다.
struct KTalkCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CloseCross()
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: KTalkCaptureStyle.closeIconLineWidth,
                        lineCap: .round
                    )
                )
                .frame(
                    width: KTalkCaptureStyle.closeIconSize,
                    height: KTalkCaptureStyle.closeIconSize
                )
                .frame(
                    width: KTalkCaptureStyle.closeButtonSize,
                    height: KTalkCaptureStyle.closeButtonSize
                )
                .background(KTalkCaptureStyle.capturePill)
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .accessibilityLabel(Text(LocalizedStrings.challenge_cancel_a11y))
    }
}

private struct CloseCross: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

/// 도면의 「보조 문구」.
struct KTalkCaptureHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(KTalkCaptureStyle.captureHint)
            .foregroundColor(KTalkCaptureStyle.captureHintColor)
            .multilineTextAlignment(.center)
    }
}

/// 도면의 「진행 표시」. SDK 가 계산한 얼굴 맞춤 정도를 타원 테두리로 옮겨 그릴 뿐이고,
/// 인증이 얼마나 끝났는지를 뜻하지 않는다.
struct KTalkOvalProgress: View {
    /// 화면 좌표로 옮긴 SDK 타원. 크기·위치를 여기서 바꾸지 않는다.
    let ovalRect: CGRect
    let progress: Double
    let color: Color

    var body: some View {
        let inset = KTalkCaptureStyle.progressInset
        let rect = ovalRect.insetBy(dx: -inset, dy: -inset)

        Ellipse()
            .trim(from: 0, to: min(max(progress, 0), 1))
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: KTalkCaptureStyle.progressStrokeWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
}
