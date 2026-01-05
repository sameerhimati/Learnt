---
name: learnt-design
description: Design system for Learnt app. Use when creating or modifying any UI components, views, or styling. Enforces the monochrome, serif, minimal aesthetic.
---

# Learnt Design System

This skill ensures all UI work follows the Learnt design philosophy.

## Core Principles

1. **Monochrome only** - No accent colors, no brand colors. Just blacks, whites, grays.
2. **Serif typography** - Use New York (iOS system serif via `.serif` design)
3. **Generous whitespace** - When in doubt, add more space
4. **Restraint** - Every element must earn its place

## Quick Reference

### Colors (see colors.md for exact values)
- Light mode: `#FAFAFA` bg, `#1A1A1A` text
- Dark mode: `#1A1A1A` bg, `#FAFAFA` text
- Never use blue, red, green, or any saturated color

### Typography (see typography.md)
- `.system(.largeTitle, design: .serif)` for dates
- `.system(.title2, design: .serif)` for headings
- `.system(.body, design: .serif)` for content
- `.system(.caption, design: .serif)` for secondary

### Spacing
- Always 8pt increments: 8, 16, 24, 32, 40, 48
- Card padding: 16pt
- Section spacing: 24pt
- Screen margins: 16pt

### Components (see components.md)
- Buttons: Circular, minimal
- Cards: Full-width, subtle shadow, 12pt radius
- Input fields: Minimal border, placeholder only
- Activity dots: Simple filled/unfilled circles

## Anti-Patterns

When reviewing or creating UI, reject:
- ❌ SF Symbols with fill (use regular weight)
- ❌ Gradients
- ❌ Shadows darker than 0.1 opacity
- ❌ Borders thicker than 1pt
- ❌ Animations longer than 300ms
- ❌ Bouncy spring animations
- ❌ Any color with saturation > 0

## Verification Checklist

Before any UI change is complete:
- [ ] All colors from Color+ extensions (no hardcoded)
- [ ] All fonts use `.serif` design
- [ ] Spacing uses 8pt grid
- [ ] Preview works in both light and dark mode
- [ ] No visual clutter
- [ ] Passes the "would removing this make it clearer?" test

See supporting files for detailed specifications.
