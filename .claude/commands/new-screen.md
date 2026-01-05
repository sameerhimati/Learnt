---
description: Create a new SwiftUI view following the project structure and design system
---

# Create New Screen

$ARGUMENTS should be the name of the screen (e.g., "Settings" or "EntryDetail")

1. Determine the appropriate folder based on the screen name:
   - Today-related → Views/Today/
   - Input-related → Views/Input/
   - Calendar-related → Views/Calendar/
   - Insights-related → Views/Insights/
   - Profile-related → Views/Profile/
   - Generic/shared → Views/

2. Create the SwiftUI file with this template:

```swift
import SwiftUI

struct {ScreenName}View: View {
    // MARK: - Properties
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Text("{ScreenName}")
                .font(.system(.title, design: .serif))
                .foregroundStyle(Color.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

// MARK: - Preview
#Preview {
    {ScreenName}View()
}
```

3. Follow design system requirements:
   - Use `.serif` design for fonts
   - Use Color extensions for theme colors
   - 8pt spacing increments
   - No hardcoded colors

4. If this screen needs a ViewModel or additional components, create those too.

5. Report what was created and suggest next steps.
