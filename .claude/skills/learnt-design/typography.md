# Typography System

## Philosophy

Learnt uses serif typography throughout. Serifs feel timeless, dignified, and literary—like a well-made journal. We use Apple's New York font via the `.serif` design option, which ensures perfect rendering and no font loading.

## Type Scale

| Style | SwiftUI | Size | Weight | Usage |
|-------|---------|------|--------|-------|
| Large Title | `.largeTitle, .serif` | 34pt | Regular | Screen titles (rarely used) |
| Title | `.title, .serif` | 28pt | Regular | Date display on Today |
| Title 2 | `.title2, .serif` | 22pt | Regular | Section headings |
| Title 3 | `.title3, .serif` | 20pt | Regular | Card titles |
| Headline | `.headline, .serif` | 17pt | Semibold | Emphasized text |
| Body | `.body, .serif` | 17pt | Regular | Entry content, primary text |
| Callout | `.callout, .serif` | 16pt | Regular | Supporting text |
| Subheadline | `.subheadline, .serif` | 15pt | Regular | Secondary info |
| Footnote | `.footnote, .serif` | 13pt | Regular | Metadata, timestamps |
| Caption | `.caption, .serif` | 12pt | Regular | Hints, tertiary text |

## SwiftUI Implementation

```swift
// Primary date display
Text("Monday, January 6")
    .font(.system(.title, design: .serif))
    .foregroundStyle(Color.primaryText)

// Entry content
Text(entry.content)
    .font(.system(.body, design: .serif))
    .foregroundStyle(Color.primaryText)

// Secondary information
Text("2 days ago")
    .font(.system(.caption, design: .serif))
    .foregroundStyle(Color.secondaryText)

// Emphasized text (rare)
Text("Your streak")
    .font(.system(.headline, design: .serif))
    .foregroundStyle(Color.primaryText)
```

## Hierarchy Rules

1. **Size creates hierarchy** - Not color, not weight
2. **One semibold per screen** - Use `.headline` sparingly
3. **Body for reading** - Entry content is always body
4. **Caption for meta** - Timestamps, counts, labels

## Line Height & Spacing

SwiftUI handles line height automatically with system fonts. For multi-line text:

```swift
Text(longContent)
    .font(.system(.body, design: .serif))
    .lineSpacing(4)  // Only if needed for readability
```

## Text Alignment

- **Titles**: Center on Today screen, left elsewhere
- **Body text**: Left aligned always
- **Captions**: Match parent alignment
- **Numbers**: Right aligned in columns

## Truncation

```swift
// Single line with ellipsis
Text(entry.content)
    .lineLimit(1)
    .truncationMode(.tail)

// Multi-line preview
Text(entry.content)
    .lineLimit(3)
    .truncationMode(.tail)
```

## Anti-Patterns

- ❌ Using `.rounded` design
- ❌ Using `.monospaced` design (except for code)
- ❌ Custom fonts (stick to system serif)
- ❌ All caps text
- ❌ Underlines for emphasis
- ❌ Color for hierarchy (use size/weight)
- ❌ More than 3 type sizes per screen

## Date Formatting

Dates should feel natural, not technical:

```swift
// Good
"Monday, January 6"
"Yesterday"
"2 days ago"

// Bad
"01/06/2026"
"2026-01-06"
"Mon, Jan 6, 2026"
```

Implementation:
```swift
extension Date {
    var displayString: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: self)
        }
    }
}
```
