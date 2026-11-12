// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation
import SPFKClassification
import SPFKTesting
import Testing

@Suite(.tags(.keywordTools))
struct MergedKeywordsTests {
    @Test func mergeModeAddsWithoutRemoving() {
        let merged = KeywordAssignment.mergedKeywords(
            result: ["Dog", "Bark"],
            snapshot: ["Dog"],
            current: ["Dog", "Typed"]
        )

        #expect(merged == ["Dog", "Typed", "Bark"])
    }

    @Test func replaceModeRemovesOnlyWhatTheToolRemoved() {
        let merged = KeywordAssignment.mergedKeywords(
            result: ["Bark"],
            snapshot: ["Old", "Dog"],
            current: ["Old", "Dog", "Typed"]
        )

        #expect(merged == ["Typed", "Bark"])
    }

    @Test func keywordRemovedMidRunStaysRemoved() {
        // The result still holds "Dog" because it was in the snapshot, which does not make it added.
        let merged = KeywordAssignment.mergedKeywords(
            result: ["Dog", "Bark"],
            snapshot: ["Dog"],
            current: []
        )

        #expect(merged == ["Bark"])
    }

    @Test func keywordAddedByBothAppearsOnceInTheUsersSpelling() {
        let merged = KeywordAssignment.mergedKeywords(
            result: ["dog"],
            snapshot: [],
            current: ["DOG"]
        )

        #expect(merged == ["DOG"])
    }

    @Test func orderIsCurrentThenResult() {
        let merged = KeywordAssignment.mergedKeywords(
            result: ["Zebra", "Apple", "Kept"],
            snapshot: ["Kept"],
            current: ["Typed", "Kept", "Also"]
        )

        #expect(merged == ["Typed", "Kept", "Also", "Zebra", "Apple"])
    }
}
