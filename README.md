# Nia Editor [WIP]
Simple minimalist photo editor on SwiftUI

## Features
- Apple's native person [segmentation](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video "segmentation") (`VNGeneratePersonSegmentationRequest`). Сool for making stickers
- `.contextMenu` implementation (animations are broken by Apple)
- Export with `ImageRenderer`

<p float="left">
<img src="https://imgur.com/m7mbkV4.png" alt="nia-editor-person-segmentation-menu" height="400">
<img src="https://imgur.com/JWpolKD.png" alt="nia-editor-person-segmentation-result" height="400">
<img src="https://imgur.com/J1E4Y6S.png" alt="nia-editor-context-menu-macos" height="400">
</p>

### Design
- Pure `SwiftUI` at any cost. Zero `UIKit` imports
- Full Apple-crossplatform.
- Only modern APIs, zero legacy support. `iOS 16+` since day one
- Zero dependencies

### Goals
- Formulate some clean and simple architecture for Apple-crossplatform `SwiftUI` media-editor projects
- Collect all the bad hacks in the world

### Why it's so messy?
- I made it
- `SwiftUI` is young and raw
- APIs and project itself is constantly changing

## Roadmap
Current tasks are [here](https://github.com/idelidel/Nia/projects/1). Big ones:

- Video support
- Video segmentation
- `PencilKit` support
- Face recognition (`VNDetectFaceLandmarksRequest`). It's already there, but I don't know why
