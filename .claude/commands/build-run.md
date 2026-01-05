---
description: Build the Xcode project and run on iOS Simulator
---

# Build and Run

1. First, find the Xcode project or workspace:
   ```bash
   ls -la *.xcodeproj *.xcworkspace 2>/dev/null
   ```

2. List available simulators:
   ```bash
   xcrun simctl list devices available | grep -E "iPhone (14|15|16)"
   ```

3. Build the project for simulator:
   ```bash
   xcodebuild -project Learnt.xcodeproj \
     -scheme Learnt \
     -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
     build
   ```

4. If build succeeds, boot the simulator if needed:
   ```bash
   xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
   ```

5. Install and launch the app:
   ```bash
   # Find the built app
   APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Learnt.app" -path "*/Debug-iphonesimulator/*" | head -1)
   
   # Install
   xcrun simctl install booted "$APP_PATH"
   
   # Launch
   xcrun simctl launch booted com.itamih.Learnt
   ```

6. Report success or any errors encountered.

If $ARGUMENTS contains a device name, use that instead of iPhone 15 Pro.
