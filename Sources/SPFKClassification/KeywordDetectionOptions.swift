// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation

/// Options for Detect Keywords, shared by every source ``KeywordDetection`` classifies.
public struct KeywordDetectionOptions: Sendable, Equatable {
    /// Range 0...1; higher yields fewer, more precise keywords. Applied to the sound and the
    /// image classifier alike.
    public var minimumConfidence: Double

    public var assignment: KeywordAssignment

    /// How the resulting keyword list is cleaned up — the same choices Organize Keywords offers.
    public var organize: OrganizeKeywordsOptions

    /// Seconds between the frames sampled from a video. Unused for audio and images.
    public var videoSamplingStep: TimeInterval

    public static let defaultConfidence: Double = 0.6

    public static let `default` = KeywordDetectionOptions()

    public init(
        minimumConfidence: Double = defaultConfidence,
        assignment: KeywordAssignment = .merge,
        organize: OrganizeKeywordsOptions = .default,
        videoSamplingStep: TimeInterval = 2.0
    ) {
        self.minimumConfidence = minimumConfidence
        self.assignment = assignment
        self.organize = organize
        self.videoSamplingStep = videoSamplingStep
    }
}
