---
description: Take a screenshot of the running simulator and analyze it
---

# Screenshot and Verify UI

1. Ensure simulator is running:
   ```bash
   xcrun simctl list devices booted
   ```
   If no simulator is booted, report and stop.

2. Take screenshot:
   ```bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   SCREENSHOT_PATH="/tmp/learnt_screenshot_${TIMESTAMP}.png"
   xcrun simctl io booted screenshot "$SCREENSHOT_PATH"
   echo "Screenshot saved to: $SCREENSHOT_PATH"
   ```

3. Display the screenshot path so it can be viewed.

4. Analyze the screenshot against the design system in CLAUDE.md:
   - Is the typography correct (serif font)?
   - Are colors monochrome (no accent colors)?
   - Is spacing generous?
   - Does it feel minimal and intentional?
   - Any elements that should be removed?

5. Report findings and suggest improvements if needed.

If $ARGUMENTS is provided, focus the analysis on that specific aspect (e.g., "colors" or "spacing").
