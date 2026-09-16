import XCTest
import Combine
import SwiftUI
import Vision
@testable import FaceLiveness
@_spi(PredictionsFaceLiveness) import AWSPredictionsPlugin

@MainActor
final class FaceLivenessDetectionViewModelTestCase: XCTestCase {
    var videoChunker: VideoChunker!
    var viewModel: FaceLivenessDetectionViewModel!
    var faceDetector: MockFaceDetector!
    var livenessService: MockLivenessService!

    override func setUp() {
        faceDetector = MockFaceDetector()
        livenessService = MockLivenessService()
        let videoChunker = VideoChunker(
            assetWriter: LivenessAVAssetWriter(),
            assetWriterDelegate: VideoChunker.AssetWriterDelegate(),
            assetWriterInput: LivenessAVAssetWriterInput()
        )

        let viewModel = FaceLivenessDetectionViewModel(
            faceDetector: faceDetector,
            faceInOvalMatching: .init(instructor: .init()),
            videoChunker: videoChunker,
            closeButtonAction: {},
            sessionID: UUID().uuidString,
            isPreviewScreenEnabled: false,
            challengeOptions: .init(faceMovementChallengeOption: .init(camera: .front),
                                    faceMovementAndLightChallengeOption: .init())
        )

        self.videoChunker = videoChunker
        self.viewModel = viewModel
    }
    
    override func tearDown() {
        self.faceDetector = nil
        self.livenessService = nil
        self.videoChunker = nil
        self.viewModel = nil
    }

    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The viewModel is first initialized
    /// Then: The state is `.intitial`
    func testInitialState() {
        // This first call comes from the FaceLivenessDetectionViewModel's initializer
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
        XCTAssertEqual(livenessService.interactions, [])

        viewModel.livenessService = self.livenessService
        XCTAssertEqual(viewModel.livenessState.state, .initial)
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
        XCTAssertEqual(livenessService.interactions, [])
    }

    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The viewModel is processes the happy path events
    /// Then: The end state of this flow is `.faceMatched`
    func testHappyPathToMatchedFace() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.challengeReceived = .faceMovementAndLightChallenge("2.0.0")

        viewModel.livenessState.checkIsFacePrepared()
        XCTAssertEqual(viewModel.livenessState.state, .pendingFacePreparedConfirmation(.pendingCheck))
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
        XCTAssertEqual(livenessService.interactions, [])

        viewModel.initializeLivenessStream()
        viewModel.process(newResult: .noFace)
        XCTAssertEqual(videoChunker.state, .pending)

        viewModel.sendInitialFaceDetectedEvent(
            initialFace: .zero,
            videoStartTime: Date().timestampMilliseconds
        )
        XCTAssertEqual(videoChunker.state, .writing)

        let initialSegment = Data([0, 1])
        var currentSegment = Data([25, 42])
        XCTAssertFalse(viewModel.hasSentFirstVideo)
        let chunk = viewModel.chunk(initial: initialSegment, current: currentSegment)
        XCTAssertEqual(chunk, initialSegment + currentSegment)
        XCTAssertTrue(viewModel.hasSentFirstVideo)

        currentSegment = Data([42, 25])
        let subsequentChunk = viewModel.chunk(initial: initialSegment, current: currentSegment)
        XCTAssertEqual(subsequentChunk, currentSegment)

        viewModel.livenessState.faceMatched()
        XCTAssertEqual(viewModel.livenessState.state, .faceMatched)
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
        XCTAssertEqual(livenessService.interactions, [
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)"
        ])
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The viewModel is processes a single face result with a face distance less than the inital face distance
    /// Then: The end state of this flow is `.recording(ovalDisplayed: false)`
    func testTransitionToRecordingState() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.challengeReceived = .faceMovementChallenge("1.0.0")
        
        let face = FaceLivenessSession.OvalMatchChallenge.Face(
            distanceThreshold: 0.32,
            distanceThresholdMax: 0.1,
            distanceThresholdMin: 0.1,
            iouWidthThreshold: 0.1,
            iouHeightThreshold: 0.1
        )
        
        let oval = FaceLivenessSession.OvalMatchChallenge.Oval(boundingBox: .init(x: 0.1,
                                                                                  y: 0.1,
                                                                                  width: 0.1,
                                                                                  height: 0.1),
                                                               heightWidthRatio: 1.618,
                                                               iouThreshold: 0.1,
                                                               iouWidthThreshold: 0.1,
                                                               iouHeightThreshold: 0.1,
                                                               ovalFitTimeout: 1)
        
        viewModel.sessionConfiguration = .faceMovement(.init(faceDetectionThreshold: 0.7,
                                                                         face: face,
                                                                         oval: oval))

        viewModel.livenessState.checkIsFacePrepared()
        XCTAssertEqual(viewModel.livenessState.state, .pendingFacePreparedConfirmation(.pendingCheck))
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
        XCTAssertEqual(livenessService.interactions, [])

        let boundingBox = CGRect(x: 0.26788579725878847, y: 0.40317180752754211, width: 0.45549795395626447, height: 0.34162446856498718)
        let leftEye = CGPoint(x: 0.61124476128552629, y: 0.4918237030506134)
        let rightEye = CGPoint(x: 0.38036393762719456, y: 0.48050540685653687)
        let nose = CGPoint(x: 0.48489856674964926, y: 0.54713362455368042)
        let mouth = CGPoint(x: 0.47411978167652435, y: 0.63170802593231201)
        let leftEar = CGPoint(x: 0.7898947484263203, y: 0.5973731875419617)
        let rightEar = CGPoint(x: 0.1658528943614037, y: 0.5668278932571411)
        let detectedFace = DetectedFace(boundingBox: boundingBox, leftEye: leftEye, rightEye: rightEye, nose: nose, mouth: mouth, rightEar: rightEar, leftEar: leftEar, confidence: 0.971859633)
        viewModel.process(newResult: .singleFace(detectedFace))
        try await Task.sleep(seconds: 1)

        XCTAssertEqual(viewModel.livenessState.state, .recording(ovalDisplayed: false))
        XCTAssertEqual(faceDetector.interactions, [
            "setResultHandler(detectionResultHandler:) (FaceLivenessDetectionViewModel)"
        ])
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The viewModel handles a no fit event over a client default time limit of 7 seconds
    /// Then: The end state is `.encounteredUnrecoverableError(.timedOut)`
    func testNoFitTimeoutCheck() async throws {
        viewModel.livenessService = self.livenessService
        self.viewModel.handleNoFaceFit(instruction: .tooFar(nearnessPercentage: 0.2), percentage: 0.2)
        
        XCTAssertNotEqual(self.viewModel.livenessState.state, .encounteredUnrecoverableError(.timedOut))
        try await Task.sleep(seconds: 6)
        self.viewModel.handleNoFaceFit(instruction: .tooFar(nearnessPercentage: 0.2), percentage: 0.2)
        XCTAssertNotEqual(self.viewModel.livenessState.state,  .encounteredUnrecoverableError(.timedOut))
        try await Task.sleep(seconds: 1)
        self.viewModel.handleNoFaceFit(instruction: .tooFar(nearnessPercentage: 0.2), percentage: 0.2)
        try await Task.sleep(seconds: 1)
        XCTAssertEqual(self.viewModel.livenessState.state,  .encounteredUnrecoverableError(.timedOut))
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The viewModel handles a no face detected event over a duration of 7 seconds
    /// Then: The end state is `.encounteredUnrecoverableError(.timedOut)`
    func testNoFaceDetectedTimeoutCheck() async throws {
        viewModel.livenessService = self.livenessService
        self.viewModel.handleNoFaceDetected()
        
        XCTAssertNotEqual(self.viewModel.livenessState.state, .encounteredUnrecoverableError(.timedOut))
        try await Task.sleep(seconds: 6)
        self.viewModel.handleNoFaceFit(instruction: .tooFar(nearnessPercentage: 0.2), percentage: 0.2)
        XCTAssertNotEqual(self.viewModel.livenessState.state,  .encounteredUnrecoverableError(.timedOut))
        try await Task.sleep(seconds: 1)
        self.viewModel.handleNoFaceDetected()
        try await Task.sleep(seconds: 1)
        XCTAssertEqual(self.viewModel.livenessState.state,  .encounteredUnrecoverableError(.timedOut))
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel` with the oval displayed (`.recording(ovalDisplayed: true)`)
    /// When: The viewModel processes a `.noFace` result
    /// Then: The instruction updates to the `.noFace` reason instead of leaving a stale one
    func testNoFaceDuringActiveCheckUpdatesInstruction() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.livenessState = .init(state: .recording(ovalDisplayed: true))

        viewModel.process(newResult: .noFace)
        try await Task.sleep(seconds: 1)

        XCTAssertEqual(viewModel.livenessState.state, .awaitingFaceInOvalMatch(.noFace, 0))
    }

    /// Given:  A `FaceLivenessDetectionViewModel` awaiting an oval match
    /// When: The viewModel processes a `.multipleFaces` result
    /// Then: The instruction updates to the `.multipleFaces` reason
    func testMultipleFacesDuringActiveCheckUpdatesInstruction() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.livenessState = .init(state: .awaitingFaceInOvalMatch(.moveFaceCloser, 0.5))

        viewModel.process(newResult: .multipleFaces)
        try await Task.sleep(seconds: 1)

        XCTAssertEqual(viewModel.livenessState.state, .awaitingFaceInOvalMatch(.multipleFaces, 0))
    }

    /// Given:  A `FaceLivenessDetectionViewModel` showing the freshness (color) flash
    /// When: The viewModel processes a `.noFace` result
    /// Then: It falls back to oval matching so a returning face can re-match and restart freshness
    func testNoFaceDuringFreshnessFallsBackToOvalMatch() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.livenessState = .init(state: .displayingFreshness)

        viewModel.process(newResult: .noFace)
        try await Task.sleep(seconds: 1)

        XCTAssertEqual(viewModel.livenessState.state, .awaitingFaceInOvalMatch(.noFace, 0))
    }

    /// Given:  A `FaceLivenessDetectionViewModel` with the oval displayed
    /// When: The viewModel processes `.noFace` results continuously past the oval-fit timeout
    /// Then: The end state is `.encounteredUnrecoverableError(.timedOut)` (client-side timeout)
    func testNoFaceDuringActiveCheckAdvancesTimeout() async throws {
        viewModel.livenessService = self.livenessService
        viewModel.livenessState = .init(state: .recording(ovalDisplayed: true))

        viewModel.process(newResult: .noFace)
        try await Task.sleep(seconds: 6)
        XCTAssertNotEqual(viewModel.livenessState.state, .encounteredUnrecoverableError(.timedOut))
        try await Task.sleep(seconds: 2)
        viewModel.process(newResult: .noFace)
        try await Task.sleep(seconds: 1)
        XCTAssertEqual(viewModel.livenessState.state, .encounteredUnrecoverableError(.timedOut))
    }

    func testCaptureInstructionsWithoutRECAndBackCancellation() async throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip("ImageRenderer requires iOS 16") }
        let cases: [(LivenessStateMachine.State, String)] = [
            (.displayingFreshness, "Hold still"),
            (.awaitingFaceInOvalMatch(.faceTooClose, 0), "Move back"),
            (.completedNoLightCheck, "Verifying")
        ]
        for (state, expectedText) in cases {
            viewModel.livenessState = .init(state: state)
            let content = _FaceLivenessDetectionView(viewModel: viewModel) {
                Color.gray.aspectRatio(3/4, contentMode: .fit)
            }
                .environment(\.colorScheme, .dark)
                .environment(\.dynamicTypeSize, .xxxLarge)
                .frame(width: 375, height: 667)
            let renderer = ImageRenderer(content: content)
            renderer.scale = 2
            let image = try XCTUnwrap(renderer.uiImage)
            let attachment = XCTAttachment(image: image)
            attachment.name = "capture-\(expectedText)-large-text"
            attachment.lifetime = .keepAlways
            add(attachment)
            let cgImage = try XCTUnwrap(image.cgImage)
            var pixel = [UInt8](repeating: 0, count: 4)
            let context = try XCTUnwrap(CGContext(
                data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            let corner = try XCTUnwrap(cgImage.cropping(to: CGRect(
                x: cgImage.width - 2, y: 2, width: 1, height: 1
            )))
            context.draw(corner, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            XCTAssertEqual(Array(pixel.prefix(3)), [255, 255, 255])
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            try VNImageRequestHandler(cgImage: XCTUnwrap(image.cgImage)).perform([request])
            let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")
            XCTAssertTrue(text.contains(expectedText), text)
            XCTAssertFalse(text.contains("REC"), text)
        }

        let cancelled = expectation(description: "Back keeps SDK user cancellation")
        let subscription = viewModel.$livenessState.sink { state in
            if state.state == .encounteredUnrecoverableError(.userCancelled) {
                cancelled.fulfill()
            }
        }
        defer { subscription.cancel() }
        KTalkBackButton(action: viewModel.closeButtonAction).action()
        await fulfillment(of: [cancelled], timeout: 2)
    }

    /// Given:  The public `FaceLivenessDetectionError` values
    /// When: Comparing `.sessionInterrupted` against `.userCancelled`
    /// Then: They are distinct so integrators can tell an interruption apart from a cancel
    func testSessionInterruptedDistinctFromUserCancelled() {
        XCTAssertNotEqual(FaceLivenessDetectionError.sessionInterrupted, .userCancelled)
    }

    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The initializeLivenessStream() is called for the first time and then called again after 3 seconds
    /// Then: The attempt count is incremented
    func testAttemptCountIncrementFirstTime() async throws {
        viewModel.livenessService = self.livenessService
        self.viewModel.initializeLivenessStream()
        XCTAssertEqual(livenessService.interactions, [
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)"
        ])
        
        XCTAssertEqual(FaceLivenessDetectionViewModel.attemptCount, 1)
        try await Task.sleep(seconds: 3)
        
        self.viewModel.initializeLivenessStream()
        XCTAssertEqual(livenessService.interactions, [
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)",
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)"
        ])
        XCTAssertEqual(FaceLivenessDetectionViewModel.attemptCount, 2)
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The attempt count is 4, last attempt time was < 5 minutes and initializeLivenessStream() is called
    /// Then: The attempt count is incremented
    func testAttemptCountIncrement() async throws {
        viewModel.livenessService = self.livenessService
        FaceLivenessDetectionViewModel.attemptCount = 4
        FaceLivenessDetectionViewModel.attemptIdTimeStamp = Date().addingTimeInterval(-180)
        self.viewModel.initializeLivenessStream()
        XCTAssertEqual(livenessService.interactions, [
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)"
        ])
        
        XCTAssertEqual(FaceLivenessDetectionViewModel.attemptCount, 5)
    }
    
    /// Given:  A `FaceLivenessDetectionViewModel`
    /// When: The attempt count is 4, last attempt time was > 5 minutes and initializeLivenessStream() is called
    /// Then: The attempt count is not incremented and reset to 1
    func testAttemptCountReset() async throws {
        viewModel.livenessService = self.livenessService
        FaceLivenessDetectionViewModel.attemptCount = 4
        FaceLivenessDetectionViewModel.attemptIdTimeStamp = Date().addingTimeInterval(-305)
        self.viewModel.initializeLivenessStream()
        XCTAssertEqual(livenessService.interactions, [
                    "initializeLivenessStream(withSessionID:userAgent:challenges:options:)"
        ])
        
        XCTAssertEqual(FaceLivenessDetectionViewModel.attemptCount, 1)
    }
}
