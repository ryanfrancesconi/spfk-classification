// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-classification

import Foundation
import SPFKBase

/// How detected keywords combine with a file's existing keywords. Raw values are persisted.
public enum KeywordAssignment: Int, Sendable, Equatable {
    /// Detected keywords are added to the existing ones.
    case merge = 0
    /// Detected keywords replace the existing ones.
    case replace = 1
}

/// How ``OrganizeKeywordsOptions/organize(_:)`` rewrites the letter case of each keyword.
/// Raw values are persisted.
public enum KeywordCase: Int, Sendable, Equatable {
    case title = 0
    case lower = 1
    /// Leaves each keyword as written, so acronyms and brand names survive.
    case preserve = 2
}

/// How a keyword list is cleaned up. The defaults title-case, replace underscores and sort, which
/// suits classifier identifiers such as `bass_drum`.
public struct OrganizeKeywordsOptions: Sendable, Equatable {
    public var keywordCase: KeywordCase

    /// Sorts the result; otherwise each keyword keeps the position of its first occurrence.
    public var sortsAlphabetically: Bool

    public var replacesUnderscores: Bool

    public static let `default` = OrganizeKeywordsOptions()

    public init(
        keywordCase: KeywordCase = .title,
        sortsAlphabetically: Bool = true,
        replacesUnderscores: Bool = true
    ) {
        self.keywordCase = keywordCase
        self.sortsAlphabetically = sortsAlphabetically
        self.replacesUnderscores = replacesUnderscores
    }

    /// `keywords` cleaned up: trimmed, empties dropped, and duplicates removed ignoring case,
    /// keeping the first spelling.
    public func organize(_ keywords: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for keyword in keywords {
            var value = replacesUnderscores ? keyword.replacingOccurrences(of: "_", with: " ") : keyword
            value = value.trimmingCharacters(in: .whitespacesAndNewlines)

            switch keywordCase {
            case .title: value = value.titleCased
            case .lower: value = value.lowercased()
            case .preserve: break
            }

            guard !value.isEmpty, seen.insert(value.lowercased()).inserted else { continue }
            result.append(value)
        }

        return sortsAlphabetically ? result.sorted() : result
    }
}
