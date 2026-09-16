//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
import Combine
@_spi(PredictionsFaceLiveness) import AWSPredictionsPlugin

struct InstructionContainerView: View {
    @ObservedObject var viewModel: FaceLivenessDetectionViewModel

    var body: some View {
        switch viewModel.livenessState.state {
        case .displayingFreshness:
            InstructionView(
                text: LocalizedStrings.challenge_instruction_hold_still,
                backgroundColor: KTalkCaptureStyle.captureBubble
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_instruction_hold_still
                )
            }

        case .awaitingFaceInOvalMatch(.faceTooClose, _):
            InstructionView(
                text: LocalizedStrings.challenge_instruction_move_face_back,
                backgroundColor: KTalkCaptureStyle.errorColor
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_instruction_move_face_back
                )
            }

        // 사용자가 움직여야 하는 안내는 도면의 강조색을 쓴다. 진행 표시는 타원
        // 테두리가 맡는다(KTalkOvalProgress).
        case .awaitingFaceInOvalMatch(let reason, _):
            InstructionView(
                text: .init(reason.localizedValue),
                backgroundColor: FaceLivenessAppearance.accent
            )
        case .recording(ovalDisplayed: true):
            InstructionView(
                text: LocalizedStrings.challenge_instruction_move_face_closer,
                backgroundColor: FaceLivenessAppearance.accent
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_instruction_move_face_closer
                )
            }
        case .pendingFacePreparedConfirmation(let reason):
            InstructionView(
                text: .init(reason.localizedValue),
                backgroundColor: KTalkCaptureStyle.captureBubble
            )
        case .completedDisplayingFreshness:
            InstructionView(
                text: LocalizedStrings.challenge_verifying,
                backgroundColor: KTalkCaptureStyle.captureBubble
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_verifying
                )
            }
        case .completedNoLightCheck:
            InstructionView(
                text: LocalizedStrings.challenge_verifying,
                backgroundColor: KTalkCaptureStyle.captureBubble
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_verifying
                )
            }
        case .faceMatched:
            if let challenge = viewModel.challengeReceived,
               case .faceMovementAndLightChallenge = challenge {
                InstructionView(
                    text: LocalizedStrings.challenge_instruction_hold_still,
                    backgroundColor: KTalkCaptureStyle.captureBubble
                )
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}
