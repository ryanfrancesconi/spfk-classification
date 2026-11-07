import Foundation
import SPFKBase
@testable import SPFKClassification
import SPFKTesting
import Testing

@Suite(.tags(.file, .keywordTools))
struct KeywordDetectionTests {
    @Test func audioReturnsSoundKeywords() async throws {
        let keywords = try await KeywordDetection.detect(
            url: TestBundleResources.shared.tabla_wav,
            source: .audio,
            existingKeywords: [],
            options: .default
        )

        #expect(keywords.contains("Tabla"))
    }

    @Test func imageMergesWithExisting() async throws {
        let keywords = try await KeywordDetection.detect(
            url: TestBundleResources.shared.songbird,
            source: .image,
            existingKeywords: ["Existing Tag"],
            options: KeywordDetectionOptions(assignment: .merge)
        )

        #expect(keywords.contains("Plant"))
        #expect(keywords.contains("Existing Tag"))
    }

    /// The fixture has no audio track, so the soundtrack half fails and the frames still answer.
    @Test func videoWithoutAudioReturnsFrameKeywords() async throws {
        let videoURL = try await StillVideoFixture.make(
            showing: [TestBundleResources.shared.songbird],
            segmentDuration: 2.0
        )
        defer { try? FileManager.default.removeItem(at: videoURL) }

        let keywords = try await KeywordDetection.detect(
            url: videoURL,
            source: .video,
            existingKeywords: [],
            options: KeywordDetectionOptions(imageConfidence: 0.1, soundConfidence: 0.1, videoSamplingStep: 1.0)
        )

        #expect(keywords.contains("Plant"))
    }

    @Test func videoKeywordsComeFromItsSoundAndItsFrames() async throws {
        let videoURL = try await StillVideoFixture.make(
            showing: [TestBundleResources.shared.songbird],
            segmentDuration: 4.0,
            soundtrack: TestBundleResources.shared.tabla_wav
        )
        defer { try? FileManager.default.removeItem(at: videoURL) }

        let keywords = try await KeywordDetection.detect(
            url: videoURL,
            source: .video,
            existingKeywords: [],
            options: KeywordDetectionOptions(imageConfidence: 0.1, soundConfidence: 0.1, videoSamplingStep: 1.0)
        )

        #expect(keywords.contains("Tabla"))
        #expect(keywords.contains("Plant"))
    }

    @Test func videoSoundtrackUsesTheSoundConfidence() async throws {
        let keywords = try await soundAndFramesKeywords(imageConfidence: 1.01, soundConfidence: 0.1)

        #expect(keywords.contains("Tabla"))
        #expect(!keywords.contains("Plant"))
    }

    @Test func videoFramesUseTheImageConfidence() async throws {
        let keywords = try await soundAndFramesKeywords(imageConfidence: 0.1, soundConfidence: 1.01)

        #expect(keywords.contains("Plant"))
        #expect(!keywords.contains("Tabla"))
    }

    private func soundAndFramesKeywords(imageConfidence: Double, soundConfidence: Double) async throws -> [String] {
        let videoURL = try await StillVideoFixture.make(
            showing: [TestBundleResources.shared.songbird],
            segmentDuration: 4.0,
            soundtrack: TestBundleResources.shared.tabla_wav
        )
        defer { try? FileManager.default.removeItem(at: videoURL) }

        return try await KeywordDetection.detect(
            url: videoURL,
            source: .video,
            existingKeywords: [],
            options: KeywordDetectionOptions(
                imageConfidence: imageConfidence,
                soundConfidence: soundConfidence,
                videoSamplingStep: 1.0
            )
        )
    }

    @Test func defaultOptionsTakeEachClassifiersDefault() {
        #expect(KeywordDetectionOptions.default.imageConfidence == ImageClassification.defaultConfidence)
        #expect(KeywordDetectionOptions.default.soundConfidence == SoundClassification.defaultConfidence)
    }

    /// The sound classifier will not open Matroska; the frames come from the demuxer.
    @Test func matroskaVideoReturnsFrameKeywords() async throws {
        let keywords = try await KeywordDetection.detect(
            url: TestBundleResources.shared.sample_mkv,
            source: .video,
            existingKeywords: [],
            options: KeywordDetectionOptions(imageConfidence: 0.1, soundConfidence: 0.1, videoSamplingStep: 0.5)
        )

        #expect(!keywords.isEmpty)
    }

    @Test func videoNothingCanReadThrows() async throws {
        await #expect(throws: (any Error).self) {
            _ = try await KeywordDetection.detect(
                url: TestBundleResources.shared.sample_avi,
                source: .video,
                existingKeywords: [],
                options: .default
            )
        }
    }

    // MARK: - assemble

    @Test func assembleMergeDedupesAndTitleCases() {
        let result = KeywordDetection.assemble(
            identifiers: ["dog_bark", "bird", "bird"],
            existingKeywords: ["Cat"],
            options: KeywordDetectionOptions(assignment: .merge)
        )

        #expect(result == ["Bird", "Cat", "Dog Bark"])
    }

    @Test func assembleReplaceDropsExisting() {
        let result = KeywordDetection.assemble(
            identifiers: ["dog_bark"],
            existingKeywords: ["Cat"],
            options: KeywordDetectionOptions(assignment: .replace)
        )

        #expect(result == ["Dog Bark"])
    }

    @Test func assembleFollowsTheOrganizeOptions() {
        let result = KeywordDetection.assemble(
            identifiers: ["sky", "dog_bark", "Sky"],
            existingKeywords: ["Cat"],
            options: KeywordDetectionOptions(
                assignment: .merge,
                organize: OrganizeKeywordsOptions(keywordCase: .lower, sortsAlphabetically: false)
            )
        )

        #expect(result == ["sky", "dog bark", "cat"])
    }
}
