//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct _FaceLivenessDetectionView<VideoView: View>: View {
    let videoView: VideoView
    @ObservedObject var viewModel: FaceLivenessDetectionViewModel
    @Binding var displayResultsView: Bool

    init(
        viewModel: FaceLivenessDetectionViewModel,
        @ViewBuilder videoView: @escaping () -> VideoView
    ) {
        self.viewModel = viewModel
        self.videoView = videoView()

        self._displayResultsView = .init(
            get: { viewModel.livenessState.state == .completed },
            set: { _ in }
        )
    }

    var body: some View {
        ZStack {
            captureContent.edgesIgnoringSafeArea(.all)
            // 안내·표시는 안전 영역 기준으로 둔다. 도면 좌표에서 상태 표시줄 54 를 뺀 값이다.
            overlay
        }
    }

    private var captureContent: some View {
        ZStack {
            Color(KTalkCaptureStyle.captureBackground)
            videoView
            if let progress = ovalProgress, screenOvalRect != .zero {
                KTalkOvalProgress(
                    ovalRect: screenOvalRect,
                    progress: progress,
                    color: FaceLivenessAppearance.accent
                )
            }
        }
    }

    private var overlay: some View {
        ZStack(alignment: .top) {
            HStack {
                KTalkRecordingBadge()
                Spacer()
                KTalkCloseButton(action: viewModel.closeButtonAction)
            }
            .padding(.horizontal, KTalkCaptureStyle.sideMargin)
            .padding(.top, KTalkCaptureStyle.captureTopMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            InstructionContainerView(viewModel: viewModel)
                .padding(.horizontal, KTalkCaptureStyle.sideMargin)
                .padding(.top, KTalkCaptureStyle.captureBubbleTop)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            KTalkCaptureHint(text: hintText)
                .padding(.horizontal, KTalkCaptureStyle.sideMargin)
                .padding(.bottom, KTalkCaptureStyle.captureHintBottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    /// SDK 가 계산한 얼굴 맞춤 정도다. 타원에 다 맞은 뒤에는 표시하지 않는다.
    private var ovalProgress: Double? {
        switch viewModel.livenessState.state {
        case .awaitingFaceInOvalMatch(.faceTooClose, _):
            return nil
        case .awaitingFaceInOvalMatch(_, let percentage):
            return percentage
        case .recording(ovalDisplayed: true):
            // 기존 진행 막대가 쓰던 시작값이다.
            return 0.2
        default:
            return nil
        }
    }

    /// SDK 가 정한 타원을 화면 좌표로 옮긴 것이다. 크기·위치는 그대로 둔다.
    private var screenOvalRect: CGRect {
        guard viewModel.ovalRect != .zero else { return .zero }
        return viewModel.ovalRect.offsetBy(
            dx: viewModel.cameraViewRect.minX,
            dy: viewModel.cameraViewRect.minY
        )
    }

    private var hintText: String {
        switch viewModel.livenessState.state {
        case .faceMatched, .displayingFreshness, .completedDisplayingFreshness:
            return LocalizedStrings.challenge_capture_hint_light
        case .awaitingFaceInOvalMatch, .recording(ovalDisplayed: true):
            return LocalizedStrings.challenge_capture_hint_progress
        default:
            return LocalizedStrings.challenge_capture_hint
        }
    }
}
