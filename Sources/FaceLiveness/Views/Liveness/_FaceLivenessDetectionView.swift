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
        ZStack(alignment: .topLeading) {
            captureContent.edgesIgnoringSafeArea(.all)
            KTalkBackButton(action: viewModel.closeButtonAction)
        }
    }

    private var captureContent: some View {
        ZStack {
            Color.white
            ZStack {
                videoView
                VStack {
                    // Preserve the instruction position independently of the navigation control.
                    Color.clear.frame(height: KTalkCaptureStyle.navBarHeight)
                    .padding(.top, 16)

                    InstructionContainerView(
                        viewModel: viewModel
                    )
                    .padding(.horizontal, KTalkCaptureStyle.sideMargin)

                    Spacer()
                }
                .aspectRatio(3/4, contentMode: .fit)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
