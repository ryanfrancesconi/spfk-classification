# SPFKClassification

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-classification)](https://github.com/ryanfrancesconi/spfk-classification/tags)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-classification%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-classification)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-classification%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-classification)

Classifies the content of sound, images and video into identifiers with confidences, for use as
keywords. Sound uses Apple's [SoundAnalysis](https://developer.apple.com/documentation/soundanalysis),
and images and video use [Vision](https://developer.apple.com/documentation/vision).

## Features

- Sound and image classification, with the built-in classifier or a custom Core ML model
- List every identifier a built-in classifier can produce
- Video classification by sampling still frames, keeping the highest confidence per identifier
- Keyword cleanup: letter case, underscores, duplicates and sorting (`OrganizeKeywordsOptions`)

## Notes

- Video sampling has no cap on frame count. Each sampled frame is a full classification.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
