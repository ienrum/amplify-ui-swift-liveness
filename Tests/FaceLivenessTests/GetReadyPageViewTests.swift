import SwiftUI
import UIKit
import Vision
import XCTest
@testable import FaceLiveness

final class GetReadyPageViewTests: XCTestCase {
    @MainActor
    func testReadyScreenInDarkMode() throws {
        try checkReadyScreen(size: CGSize(width: 390, height: 844), accent: 0xFFFF7A59)
    }

    @MainActor
    func testReadyScreenOnSmallDisplay() throws {
        try checkReadyScreen(size: CGSize(width: 375, height: 667), accent: 0xFF6759FF)
    }

    @MainActor
    private func checkReadyScreen(size: CGSize, accent: UInt32) throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip("ImageRenderer requires iOS 16") }
        let previousAccent = FaceLivenessAppearance.accentARGB
        FaceLivenessAppearance.accentARGB = accent
        defer { FaceLivenessAppearance.accentARGB = previousAccent }
        let view = GetReadyPageView(
            onBegin: {},
            cameraPosition: .front,
            onBack: {}
        )
        .environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 2
        let image = try XCTUnwrap(renderer.uiImage)
        let attachment = XCTAttachment(image: image)
        attachment.name = "iOS-ready-\(Int(size.width))x\(Int(size.height))-dark"
        attachment.lifetime = .keepAlways
        add(attachment)

        let cgImage = try XCTUnwrap(image.cgImage)
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "ko-KR"]
        try VNImageRequestHandler(cgImage: cgImage).perform([request])
        let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: " ")
        let title = "amplify_ui_liveness_challenge_title".localized()
        XCTAssertEqual(text.components(separatedBy: title).count - 1, 1, text)
        XCTAssertFalse(text.localizedCaseInsensitiveContains("photosensitivity"), text)
        XCTAssertFalse(text.contains("광과민성"), text)
        XCTAssertTrue(text.contains("amplify_ui_liveness_get_ready_begin_check".localized()), text)

        // The outer background must stay white even when SwiftUI uses dark mode.
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = try XCTUnwrap(CGContext(
            data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        let corner = try XCTUnwrap(cgImage.cropping(to: CGRect(x: 2, y: 2, width: 1, height: 1)))
        context.draw(corner, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(Array(pixel.prefix(3)), [255, 255, 255])
    }
}
