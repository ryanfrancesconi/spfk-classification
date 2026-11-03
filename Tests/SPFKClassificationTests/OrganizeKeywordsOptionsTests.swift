// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation
import SPFKClassification
import SPFKTesting
import Testing

@Suite(.tags(.keywordTools))
struct OrganizeKeywordsOptionsTests {
    @Test func defaultsTitleCaseSortAndReplaceUnderscores() {
        #expect(OrganizeKeywordsOptions.default.organize(["zebra", "bass_drum", "apple"]) == ["Apple", "Bass Drum", "Zebra"])
    }

    @Test func preserveKeepsAcronymsAndDedupesIgnoringCase() {
        let options = OrganizeKeywordsOptions(keywordCase: .preserve)

        #expect(options.organize(["UCS", "ucs", "iPhone"]) == ["UCS", "iPhone"])
    }

    @Test func dedupeKeepsTheFirstSpelling() {
        let options = OrganizeKeywordsOptions(keywordCase: .preserve, sortsAlphabetically: false)

        #expect(options.organize(["iPhone", "IPHONE", "Dog", "dog"]) == ["iPhone", "Dog"])
    }

    @Test func unsortedKeepsFirstOccurrenceOrder() {
        let options = OrganizeKeywordsOptions(sortsAlphabetically: false)

        #expect(options.organize(["zebra", "apple", "Zebra", "mango"]) == ["Zebra", "Apple", "Mango"])
    }

    @Test func underscoresSurviveWhenNotReplaced() {
        let options = OrganizeKeywordsOptions(keywordCase: .lower, replacesUnderscores: false)

        #expect(options.organize(["Bass_Drum", " ", ""]) == ["bass_drum"])
    }
}
