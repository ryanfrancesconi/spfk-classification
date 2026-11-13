// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation

/// Options for Detect Keywords, shared by every source ``KeywordDetection`` classifies.
public struct KeywordDetectionOptions: Sendable, Equatable {
    /// The image classifier's cutoff, range 0...1: images, and a video's frames.
    public var imageConfidence: Double

    /// The sound classifier's cutoff, range 0...1: audio, and a video's soundtrack.
    public var soundConfidence: Double

    public var assignment: KeywordAssignment

    /// How the resulting keyword list is cleaned up - the same choices Organize Keywords offers.
    public var organize: OrganizeKeywordsOptions

    /// Seconds between the frames sampled from a video. Unused for audio and images.
    public var videoSamplingStep: TimeInterval

    public static let `default` = KeywordDetectionOptions()

    public init(
        imageConfidence: Double = ImageClassification.defaultConfidence,
        soundConfidence: Double = SoundClassification.defaultConfidence,
        assignment: KeywordAssignment = .merge,
        organize: OrganizeKeywordsOptions = .default,
        videoSamplingStep: TimeInterval = 2.0
    ) {
        self.imageConfidence = imageConfidence
        self.soundConfidence = soundConfidence
        self.assignment = assignment
        self.organize = organize
        self.videoSamplingStep = videoSamplingStep
    }
}
