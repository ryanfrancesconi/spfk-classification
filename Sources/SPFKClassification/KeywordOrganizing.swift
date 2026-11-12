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

extension KeywordAssignment {
    /// The keywords after merging a tool's result into a list the user may have edited meanwhile.
    ///
    /// What the tool added (`result` − `snapshot`) is appended to `current`, and what it removed
    /// (`snapshot` − `result`) is dropped from it, so keywords the user added or removed mid-run
    /// keep their edit. Comparison ignores case; duplicates keep their first spelling.
    public static func mergedKeywords(result: [String], snapshot: [String], current: [String]) -> [String] {
        let snapshotKeys = Set(snapshot.map { $0.lowercased() })
        let resultKeys = Set(result.map { $0.lowercased() })

        let removed = snapshotKeys.subtracting(resultKeys)
        let added = result.filter { !snapshotKeys.contains($0.lowercased()) }

        var seen = Set<String>()
        var merged: [String] = []

        for keyword in current where !removed.contains(keyword.lowercased()) {
            if seen.insert(keyword.lowercased()).inserted { merged.append(keyword) }
        }

        for keyword in added where seen.insert(keyword.lowercased()).inserted {
            merged.append(keyword)
        }

        return merged
    }
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
