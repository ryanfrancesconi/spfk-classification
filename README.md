# SPFKClassification

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-classification)](https://github.com/ryanfrancesconi/spfk-classification/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-classification%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-classification)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-classification%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-classification)

Names what is in a sound, an image or a video, as identifiers with confidences, so they can
become keywords. Sound goes through Apple's
[SoundAnalysis](https://developer.apple.com/documentation/soundanalysis), images and video through
[Vision](https://developer.apple.com/documentation/vision), and either accepts a custom Core ML model
in place of the built-in classifier.

Each built-in classifier can list everything it is able to name, so an app can build a vocabulary
from it. Video is classified by sampling still frames and keeping the best confidence per identifier
across them, as sound does across its analysis windows.

Frame extraction belongs to spfk-video. Turning results into tags, and the UI around that, belongs
to the products' processing packages.

## Constraints

- A custom model must be compiled (`.mlmodelc`). Compiling writes to a temporary location, so keep
  the result rather than compiling on every launch. An image model whose observations are not
  classifications yields an empty result, not an error.
- Video sampling has no cap on frame count. Each sampled frame is a full classification, so a caller
  exposing the sampling step has to bound that cost or make it visible.
- The sound and image confidence defaults are calibrated separately against each framework's output;
  tuning one says nothing about the other.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).
