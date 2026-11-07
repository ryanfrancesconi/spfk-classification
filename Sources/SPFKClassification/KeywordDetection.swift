// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation
import SPFKBase

/// What ``KeywordDetection`` classifies a file as.
public enum KeywordDetectionSource: Sendable {
    /// The sound classifier.
    case audio
    /// The image classifier.
    case image
    /// The soundtrack and the sampled frames together.
    case video
}

/// Detects keywords for one file. Batch iteration belongs to each product's processor.
public enum KeywordDetection {
    /// The file's keywords: merged with or replacing `existingKeywords` per `options.assignment`,
    /// then organized.
    ///
    /// A `.video` throws only when both halves fail, so a soundtrack that cannot be opened or a
    /// file with no audio stream still yields the frames' keywords.
    public static func detect(
        url: URL,
        source: KeywordDetectionSource,
        existingKeywords: [String],
        options: KeywordDetectionOptions
    ) async throws -> [String] {
        let identifiers: [String] = switch source {
        case .audio:
            try await soundIdentifiers(url: url, options: options)
        case .image:
            try await imageIdentifiers(url: url, options: options)
        case .video:
            try await videoIdentifiers(url: url, options: options)
        }

        try Task.checkCancellation()

        return assemble(identifiers: identifiers, existingKeywords: existingKeywords, options: options)
    }

    static func assemble(
        identifiers: [String],
        existingKeywords: [String],
        options: KeywordDetectionOptions
    ) -> [String] {
        var allKeywords = identifiers

        if options.assignment == .merge {
            allKeywords += existingKeywords
        }

        return options.organize.organize(allKeywords)
    }

    // MARK: - Sources

    private static func soundIdentifiers(url: URL, options: KeywordDetectionOptions) async throws -> [String] {
        let classifications = try await SoundClassification.analyze(
            url: url,
            minimumConfidence: options.soundConfidence
        )
        return classifications?.map(\.identifier) ?? []
    }

    private static func imageIdentifiers(url: URL, options: KeywordDetectionOptions) async throws -> [String] {
        guard let classifications = try await ImageClassification.analyze(
            url: url,
            minimumConfidence: options.imageConfidence
        ) else {
            throw NSError(description: "Failed to classify \(url.lastPathComponent)")
        }
        return classifications.map(\.identifier)
    }

    private static func frameIdentifiers(url: URL, options: KeywordDetectionOptions) async throws -> [String] {
        guard let classifications = try await ImageClassification.analyzeVideo(
            url: url,
            sampling: .fixedInterval(step: options.videoSamplingStep),
            minimumConfidence: options.imageConfidence
        ) else {
            throw NSError(description: "Failed to classify the frames of \(url.lastPathComponent)")
        }
        return classifications.map(\.identifier)
    }

    /// Sound first, then frames, run one after the other.
    private static func videoIdentifiers(url: URL, options: KeywordDetectionOptions) async throws -> [String] {
        var sound: [String]?

        do {
            sound = try await soundIdentifiers(url: url, options: options)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            Log.debug("No soundtrack keywords for \(url.lastPathComponent): \(error.localizedDescription)")
        }

        try Task.checkCancellation()

        do {
            return try await (sound ?? []) + frameIdentifiers(url: url, options: options)
        } catch {
            guard let sound, !(error is CancellationError) else { throw error }
            Log.debug("No frame keywords for \(url.lastPathComponent): \(error.localizedDescription)")
            return sound
        }
    }
}
