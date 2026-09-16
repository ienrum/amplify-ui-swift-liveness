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
                backgroundColor: .white,
                textColor: KTalkCaptureStyle.titleColor,
                font: KTalkCaptureStyle.instruction
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
                backgroundColor: .white,
                textColor: KTalkCaptureStyle.errorColor,
                font: KTalkCaptureStyle.instruction
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_instruction_move_face_back
                )
            }

        case .awaitingFaceInOvalMatch(let reason, let percentage):
            InstructionView(
                text: .init(reason.localizedValue),
                backgroundColor: .white,
                textColor: KTalkCaptureStyle.titleColor,
                font: KTalkCaptureStyle.instruction
            )

            ProgressBarView(
                emptyColor: .white,
                borderColor: .hex("#AEB3B7"),
                fillColor: FaceLivenessAppearance.accent,
                indicatorColor: FaceLivenessAppearance.accent,
                percentage: percentage
            )
            .frame(width: 200, height: 30)
        case .recording(ovalDisplayed: true):
            InstructionView(
                text: LocalizedStrings.challenge_instruction_move_face_closer,
                backgroundColor: .white,
                textColor: KTalkCaptureStyle.titleColor,
                font: KTalkCaptureStyle.instruction
            )
            .onAppear {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: LocalizedStrings.challenge_instruction_move_face_closer
                )
            }

            ProgressBarView(
                emptyColor: .white,
                borderColor: .hex("#AEB3B7"),
                fillColor: FaceLivenessAppearance.accent,
                indicatorColor: FaceLivenessAppearance.accent,
                percentage: 0.2
            )
            .frame(width: 200, height: 30)
        case .pendingFacePreparedConfirmation(let reason):
            InstructionView(
                text: .init(reason.localizedValue),
                backgroundColor: .white,
                textColor: KTalkCaptureStyle.titleColor,
                font: KTalkCaptureStyle.instruction
            )
        case .completedDisplayingFreshness:
            InstructionView(
                text: LocalizedStrings.challenge_verifying,
                backgroundColor: .white
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
                backgroundColor: .white
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
                    backgroundColor: .white,
                    textColor: KTalkCaptureStyle.titleColor,
                    font: KTalkCaptureStyle.instruction
                )
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}
