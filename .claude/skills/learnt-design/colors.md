# Color System

## Philosophy

Learnt uses a strictly monochrome palette. This isn't a limitation—it's a feature. The absence of color creates focus, reduces visual noise, and reinforces the contemplative nature of the app.

## Light Mode

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Background | `#FAFAFA` | 250, 250, 250 | Primary background |
| Primary Text | `#1A1A1A` | 26, 26, 26 | Headings, body text |
| Secondary Text | `#6B6B6B` | 107, 107, 107 | Captions, hints, metadata |
| Tertiary Text | `#9B9B9B` | 155, 155, 155 | Disabled states, placeholders |
| Divider | `#E8E8E8` | 232, 232, 232 | Separators, borders |
| Surface | `#F5F5F5` | 245, 245, 245 | Cards, input fields |
| Elevated | `#FFFFFF` | 255, 255, 255 | Modals, overlays |

## Dark Mode

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Background | `#1A1A1A` | 26, 26, 26 | Primary background |
| Primary Text | `#FAFAFA` | 250, 250, 250 | Headings, body text |
| Secondary Text | `#9B9B9B` | 155, 155, 155 | Captions, hints, metadata |
| Tertiary Text | `#6B6B6B` | 107, 107, 107 | Disabled states, placeholders |
| Divider | `#2A2A2A` | 42, 42, 42 | Separators, borders |
| Surface | `#252525` | 37, 37, 37 | Cards, input fields |
| Elevated | `#2F2F2F` | 47, 47, 47 | Modals, overlays |

## SwiftUI Implementation

```swift
import SwiftUI

extension Color {
    // MARK: - Background
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let elevated = Color("Elevated")
    
    // MARK: - Text
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let tertiaryText = Color("TertiaryText")
    
    // MARK: - UI Elements
    static let divider = Color("Divider")
}

extension ShapeStyle where Self == Color {
    static var primaryText: Color { .primaryText }
    static var secondaryText: Color { .secondaryText }
}
```

## Asset Catalog Setup

In Assets.xcassets, create color sets:

```
Colors/
├── Background.colorset
├── Surface.colorset
├── Elevated.colorset
├── PrimaryText.colorset
├── SecondaryText.colorset
├── TertiaryText.colorset
└── Divider.colorset
```

Each colorset should have:
- Any Appearance: Light mode value
- Dark Appearance: Dark mode value

## Usage Rules

1. **Never hardcode colors** - Always use Color extensions
2. **Never use system colors** - No `.blue`, `.red`, `.primary`
3. **Never add new colors** - Work within this palette
4. **Test both modes** - Every screen must work in light and dark

## Semantic Usage

- **Primary Text**: Entry content, dates, headings
- **Secondary Text**: Timestamps, labels, supporting info
- **Tertiary Text**: Placeholders, disabled buttons
- **Divider**: Separators, subtle borders (1pt max)
- **Surface**: Cards, input backgrounds
- **Elevated**: Modals, popovers, action sheets
