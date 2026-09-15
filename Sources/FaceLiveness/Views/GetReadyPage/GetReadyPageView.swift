//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct GetReadyPageView: View {
    let beginCheckButtonDisabled: Bool
    let onBegin: () -> Void
    let cameraPosition: LivenessCamera
    
    init(
        onBegin: @escaping () -> Void,
        beginCheckButtonDisabled: Bool = false,
        cameraPosition: LivenessCamera
    ) {
        self.onBegin = onBegin
        self.beginCheckButtonDisabled = beginCheckButtonDisabled
        self.cameraPosition = cameraPosition
    }

    var body: some View {
        VStack {
            ZStack {
                CameraPreviewView(cameraPosition: cameraPosition)
                VStack(alignment: .leading, spacing: KTalkCaptureStyle.titleToDescription) {
                    Text("amplify_ui_liveness_challenge_title".localized())
                        .font(KTalkCaptureStyle.title)
                        .foregroundColor(KTalkCaptureStyle.titleColor)
                    Text("amplify_ui_liveness_challenge_description".localized())
                        .font(KTalkCaptureStyle.description)
                        .foregroundColor(KTalkCaptureStyle.descriptionColor)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, KTalkCaptureStyle.sideMargin)
                .padding(.top, KTalkCaptureStyle.titleTopFromNavBar)
            }
            beginCheckButton
        }
        .background(Color.white.ignoresSafeArea())
    }

    // KTalk fork: 보조 문구와 시작 버튼. 동작은 그대로 onBegin 이다.
    private var beginCheckButton: some View {
        VStack(alignment: .leading, spacing: KTalkCaptureStyle.hintToButton) {
            Text("amplify_ui_liveness_challenge_hint".localized())
                .font(KTalkCaptureStyle.hint)
                .foregroundColor(KTalkCaptureStyle.descriptionColor)
            Button(
                action: onBegin,
                label: {
                    Text(LocalizedStrings.get_ready_begin_check)
                        .font(KTalkCaptureStyle.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: KTalkCaptureStyle.buttonHeight)
                        .background(FaceLivenessAppearance.accent)
                        .cornerRadius(KTalkCaptureStyle.buttonCorner)
                }
            )
            .disabled(beginCheckButtonDisabled)
        }
        .padding(.horizontal, KTalkCaptureStyle.sideMargin)
        .padding(.bottom, KTalkCaptureStyle.buttonBottomMargin)
    }
}

struct GetReadyPageView_Previews: PreviewProvider {
    static var previews: some View {
        GetReadyPageView(
            onBegin: {},
            cameraPosition: .front)
    }
}
