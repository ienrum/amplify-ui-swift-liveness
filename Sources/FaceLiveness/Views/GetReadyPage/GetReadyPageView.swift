//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
@_spi(PredictionsFaceLiveness) import AWSPredictionsPlugin

struct GetReadyPageView: View {
    let beginCheckButtonDisabled: Bool
    let onBegin: () -> Void
    let challenge: Challenge
    let cameraPosition: LivenessCamera
    
    init(
        onBegin: @escaping () -> Void,
        beginCheckButtonDisabled: Bool = false,
        challenge: Challenge,
        cameraPosition: LivenessCamera
    ) {
        self.onBegin = onBegin
        self.beginCheckButtonDisabled = beginCheckButtonDisabled
        self.challenge = challenge
        self.cameraPosition = cameraPosition
    }

    var body: some View {
        VStack {
            ZStack {
                CameraPreviewView(cameraPosition: cameraPosition)
                VStack {
                    WarningBox(
                        titleText: LocalizedStrings.get_ready_photosensitivity_title,
                        bodyText: LocalizedStrings.get_ready_photosensitivity_description,
                        popoverContent: { photosensitivityWarningPopoverContent }
                    )
                    .accessibilityElement(children: .combine)
                    .opacity(challenge == Challenge.faceMovementAndLightChallenge("2.0.0") ? 1.0 : 0.0)
                    Text(LocalizedStrings.preview_center_your_face_text)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Spacer()
                }.padding()

                // KTalk fork: 준비 화면의 제목·설명. 광과민성 고지와 SDK 안내는
                // 그대로 둔다 — 고지를 가리거나 대체하지 않는다.
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
        .cornerRadius(14)
        .padding([.leading, .trailing])
        .padding(.bottom, 16)
    }

    private var photosensitivityWarningPopoverContent: some View {
        VStack {
            Text(LocalizedStrings.get_ready_photosensitivity_dialog_title)
                .font(.system(size: 20, weight: .medium))
                .frame(alignment: .center)
                .padding()
            Text(LocalizedStrings.get_ready_photosensitivity_dialog_description)
                .padding()
            Spacer()
        }
    }
}

struct GetReadyPageView_Previews: PreviewProvider {
    static var previews: some View {
        GetReadyPageView(
            onBegin: {},
            challenge: .faceMovementAndLightChallenge("2.0.0"),
            cameraPosition: .front)
    }
}
