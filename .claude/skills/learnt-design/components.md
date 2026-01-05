# Component Library

## Philosophy

Components are intentionally minimal. If a component seems too simple, it's probably right. Complexity should live in content, not chrome.

---

## Activity Dots

The week activity indicator. Simple filled/unfilled circles.

```swift
struct ActivityDots: View {
    let entries: [Date: Bool]  // Date -> hasEntry
    let currentDate: Date
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDates, id: \.self) { date in
                Circle()
                    .fill(hasEntry(for: date) ? Color.primaryText : Color.divider)
                    .frame(width: 8, height: 8)
                    .opacity(isSelected(date) ? 1.0 : 0.6)
                    .onTapGesture {
                        selectedDate = date
                    }
            }
        }
    }
    
    private var weekDates: [Date] {
        // Return 7 dates centered on currentDate
    }
}
```

**Specs:**
- Dot size: 8pt diameter
- Spacing: 12pt between dots
- Filled: primaryText color
- Unfilled: divider color
- Selected: Full opacity
- Unselected: 0.6 opacity
- Tap target: Extend to 44pt (accessibility)

---

## Add Button

The floating action button that expands to show input options.

```swift
struct AddButton: View {
    @Binding var isExpanded: Bool
    let onVoice: () -> Void
    let onText: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if isExpanded {
                // Mic button
                CircleButton(icon: "mic", action: onVoice)
                    .transition(.scale.combined(with: .opacity))
                
                // Text button
                CircleButton(icon: "character.cursor.ibeam", action: onText)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Main + button
            CircleButton(
                icon: isExpanded ? "xmark" : "plus",
                size: .large,
                action: { withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() } }
            )
        }
    }
}

struct CircleButton: View {
    enum Size { case regular, large }
    
    let icon: String
    var size: Size = .regular
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size == .large ? 24 : 18))
                .foregroundStyle(Color.primaryText)
                .frame(width: size == .large ? 56 : 44, height: size == .large ? 56 : 44)
                .background(Color.surface)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}
```

**Specs:**
- Large button: 56pt diameter
- Regular button: 44pt diameter
- Icon size: 24pt (large), 18pt (regular)
- Shadow: 8pt blur, 4pt y-offset, 0.08 opacity
- Animation: 200ms ease-out
- Icons: SF Symbols, regular weight

---

## Entry Card

Displays a learning entry.

```swift
struct EntryCard: View {
    let entry: LearningEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                
                HStack {
                    if entry.isVoiceEntry {
                        Image(systemName: "waveform")
                            .font(.caption)
                    }
                    Text(entry.createdAt, style: .time)
                        .font(.system(.caption, design: .serif))
                }
                .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.surface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
```

**Specs:**
- Padding: 16pt all sides
- Corner radius: 12pt
- Background: surface color
- No border (background provides definition)
- Content alignment: left
- Line limit: none (show full content)

---

## Empty State

When there's no entry for a day.

```swift
struct EmptyState: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What did you learn today?")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}
```

**Specs:**
- Text: title3 serif, secondary color
- Centered
- Generous padding (32pt)
- No illustrations or icons (keep it textual)

---

## Tab Bar

Custom bottom navigation.

```swift
struct LearntTabBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab: String, CaseIterable {
        case insights = "lightbulb"
        case today = "book"
        case profile = "person"
    }
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button {
                    selectedTab = tab
                } label: {
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 20))
                        .foregroundStyle(
                            selectedTab == tab ? Color.primaryText : Color.tertiaryText
                        )
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(Color.background)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
```

**Specs:**
- Icon size: 20pt
- Tap target: 44pt
- Selected: primaryText
- Unselected: tertiaryText
- No labels (icons only)
- Top divider
- Background matches screen

---

## Calendar Overlay

Month view for date navigation.

```swift
struct CalendarOverlay: View {
    @Binding var selectedDate: Date
    let entriesExist: [Date: Bool]
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Month/Year header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString)
                    .font(.system(.headline, design: .serif))
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(Color.primaryText)
            .padding(.horizontal, 16)
            
            // Day grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.tertiaryText)
                }
                
                // Day numbers with dots
                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(
                        date: date,
                        hasEntry: entriesExist[date] ?? false,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: Calendar.current.isDateInToday(date)
                    ) {
                        selectedDate = date
                        onDismiss()
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
        .background(Color.elevated)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
    }
}

struct DayCell: View {
    let date: Date
    let hasEntry: Bool
    let isSelected: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(
                        isSelected ? Color.background : 
                        isToday ? Color.primaryText : Color.secondaryText
                    )
                
                Circle()
                    .fill(hasEntry ? Color.primaryText : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(width: 40, height: 48)
            .background(isSelected ? Color.primaryText : Color.clear)
            .cornerRadius(8)
        }
    }
}
```

**Specs:**
- Day cell: 40x48pt
- Entry dot: 4pt
- Selected state: inverted colors (text on dark bg)
- Today: primary text, not selected
- Corner radius: 8pt on cells, 16pt on overlay
- Shadow: 16pt blur, 8pt y-offset, 0.1 opacity

---

## Voice Input View

Recording state with waveform visualization.

```swift
struct VoiceInputView: View {
    @Binding var isRecording: Bool
    let onStop: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Waveform placeholder (simple pulsing circle for v1)
            Circle()
                .fill(Color.surface)
                .frame(width: 120, height: 120)
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                .overlay {
                    Image(systemName: "waveform")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.primaryText)
                }
            
            Text("Listening...")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryText)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 48) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryText)
                }
                
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: 64, height: 64)
                        .background(Color.surface)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}
```

**Specs:**
- Waveform circle: 120pt diameter
- Pulse animation: 0.5s ease-in-out, autoreverses
- Stop button: 64pt diameter
- Cancel: text button, secondary color
- Full screen modal

---

## Input Transition Notes

The + button expansion should feel natural:

1. **Collapsed**: Just the + button
2. **Expanding**: + rotates 45° to become x, other buttons scale in from center
3. **Expanded**: Three stacked buttons
4. **Selecting option**: Other buttons fade, selected animates to full screen

Animation duration: 200ms for expansion, 300ms for transition to full input view.
