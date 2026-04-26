Open `MathFactInvaders.xcodeproj` in Xcode:

1. In Finder, open the folder `swift-ios` and double-click `MathFactInvaders.xcodeproj`.
2. Select a simulator (e.g., iPhone 14) and press Run.

Notes:
- The project contains the SwiftUI + SpriteKit source files: `MathFactInvadersApp.swift`, `ContentView.swift`, `GameModel.swift`, `GameScene.swift`.
- Deployment target is set to iOS 15.0; change in project settings if needed.

- The `Assets.xcassets` includes an `AppIcon.appiconset` with placeholder file names — replace the PNG placeholders with your icon images (e.g., `icon-60@3x.png`).
- Launch screen storyboard `Base.lproj/LaunchScreen.storyboard` is included.
- The `Assets.xcassets` includes an `AppIcon.appiconset` with placeholder file names — you can replace the PNG placeholders with your icon images.
- To auto-generate simple placeholders (1x1 transparent PNGs) run the included PowerShell script from the `swift-ios` folder:

```powershell
./generate-icons.ps1
```

