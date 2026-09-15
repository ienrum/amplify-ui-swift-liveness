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
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("amplify_ui_liveness_challenge_title"))
                        .font(.title2.bold())
                        .foregroundColor(.livenessLabel)
                    Text(LocalizedStringKey("amplify_ui_liveness_challenge_description"))
                        .font(.subheadline)
                        .foregroundColor(.livenessLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Text(LocalizedStringKey("amplify_ui_liveness_challenge_hint"))
                    .font(.subheadline)
                    .foregroundColor(.livenessLabel)
                    .padding(.bottom, 16)

                Button(action: viewModel.closeButtonAction) {
                    Text(LocalizedStringKey("amplify_ui_liveness_challenge_cancel"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.ktalkAccent)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 32)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
