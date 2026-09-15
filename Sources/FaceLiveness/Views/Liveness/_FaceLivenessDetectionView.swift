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
        // KTalk fork: capture screen publishing. The preview, oval overlay, freshness
        // area and screen brightness behaviour are untouched — only the surrounding
        // chrome (background, header, cancel affordance) is KTalk's.
        ZStack {
            Color.livenessBackground
            ZStack {
                videoView
                VStack {
                    HStack(alignment: .top) {
                        if viewModel.livenessState.shouldDisplayRecordingIcon {
                            RecordingButton()
                                .accessibilityHidden(true)
                        }

                        Spacer()
                    }
                    .padding()

                    InstructionContainerView(
                        viewModel: viewModel
                    )

                    Spacer()
                }
                .padding([.leading, .trailing])
                .aspectRatio(3/4, contentMode: .fit)
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: KTalkCaptureStyle.titleToDescription) {
                    Text("amplify_ui_liveness_challenge_title".localized())
                        .font(KTalkCaptureStyle.title)
                        .foregroundColor(KTalkCaptureStyle.titleColor)
                    Text("amplify_ui_liveness_challenge_description".localized())
                        .font(KTalkCaptureStyle.description)
                        .foregroundColor(KTalkCaptureStyle.descriptionColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Text("amplify_ui_liveness_challenge_hint".localized())
                    .font(KTalkCaptureStyle.hint)
                    .foregroundColor(KTalkCaptureStyle.descriptionColor)
                    .padding(.bottom, KTalkCaptureStyle.hintToButton)

                Button(action: viewModel.closeButtonAction) {
                    Text("amplify_ui_liveness_challenge_cancel".localized())
                        .font(KTalkCaptureStyle.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: KTalkCaptureStyle.buttonHeight)
                        .background(FaceLivenessAppearance.accent)
                        .cornerRadius(KTalkCaptureStyle.buttonCorner)
                }
            }
            .padding(.horizontal, KTalkCaptureStyle.sideMargin)
            .padding(.top, KTalkCaptureStyle.titleTopFromNavBar)
            .padding(.bottom, KTalkCaptureStyle.buttonBottomMargin)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
