---
name: swiftui
description: SwiftUI patterns for toolbars, styled text editing, and WebKit integration.
compatibility: iOS/iPadOS/macOS (modern SwiftUI); some APIs require recent OS versions.
allowed-tools: Read
metadata:
  author: timsearle
  version: "1.0"
---

# SwiftUI implementation skill

Use this skill when the user asks for SwiftUI view code, toolbar customization, styled text editing, or WebKit integration with WebView/WebPage.

## Activation cues

- "SwiftUI toolbar", "customizable toolbar", "search toolbar behavior"
- "AttributedString", "TextEditor", "rich text", "styled text"
- "WebView", "WebPage", "SwiftUI + WebKit", "callJavaScript"

## Toolbar patterns (modern SwiftUI)

### Customizable toolbars
Create a customizable toolbar with IDs for every item:

```swift
ContentView()
    .toolbar(id: "main-toolbar") {
        ToolbarItem(id: "tag") { TagButton() }
        ToolbarItem(id: "share") { ShareButton() }
        ToolbarSpacer(.fixed)
        ToolbarItem(id: "more") { MoreButton() }
    }
```

Use ToolbarSpacer(.fixed) to separate groups or ToolbarSpacer(.flexible) to push items apart.

### Search integration
- Minimize search to save space: .searchToolbarBehavior(.minimize)
- Reposition search with DefaultToolbarItem:

```swift
DefaultToolbarItem(kind: .search, placement: .bottomBar)
```

### New placements and transitions
- Use .largeSubtitle to place custom content in the large subtitle area.
- Use matchedTransitionSource on toolbar items for coordinated transitions.

### Best practices
- Use meaningful item IDs.
- Group related actions together.
- Prefer system-defined toolbar items for platform consistency.
- Test customization flows on macOS if supported.
- For UI alignment/gesture fixes, verify in Simulator with a screenshot or visual check before declaring complete.

## Gesture performance patterns

### Smooth dragging with @GestureState
For drag-to-reveal sliders or position handles, use `@GestureState` instead of updating `@Binding` on every `.onChanged`. This keeps state local during the gesture and only commits on `.onEnded`:

```swift
@GestureState private var dragOffset: CGFloat = 0
@Binding var position: CGFloat

.gesture(
    DragGesture()
        .updating($dragOffset) { value, state, _ in
            state = value.translation.width
        }
        .onEnded { value in
            position = clamp(position + value.translation.width / width, 0...1)
        }
)
```

### Comparison slider ranges
For photo/overlay comparison sliders, use full 0.0-1.0 range. Clipping to 0.05-0.95 prevents the user from seeing 100% of either layer.

## Styled text and editing

### Display rich text with AttributedString

```swift
var text = AttributedString("Red and Blue")
if let redRange = text.range(of: "Red") {
    text[redRange].foregroundColor = .red
}
if let blueRange = text.range(of: "Blue") {
    text[blueRange].foregroundColor = .blue
}

Text(text)
```

### Edit rich text with TextEditor

```swift
@State private var text = AttributedString("Editable styled text")
@State private var selection = AttributedTextSelection()

TextEditor(text: $text, selection: $selection)
```

Use transformAttributes(in:) with the selection to toggle bold/italic/underline or color.

### Formatting constraints
Define constraints with AttributedTextFormattingDefinition when you need controlled formatting rules.

### Markdown support (Text only)
Text supports a limited Markdown subset (bold, italic, links). It does not support block elements, tables, or images.

### Performance and accessibility
- Avoid recreating large AttributedString values on every render.
- Use Dynamic Type and accessibility labels for rich text surfaces.

## WebKit integration (WebView + WebPage)

### Basic WebView

```swift
WebView(url: URL(string: "https://www.apple.com"))
```

### Managed WebPage

```swift
@State private var page = WebPage()

WebView(page)
    .navigationTitle(page.title)
```

### Configuration
Use WebPage.Configuration to control subresource loading, JavaScript permissions, and data stores.

### Navigation and state
Track page.currentNavigationEvent to show loading UI or handle errors. Use a NavigationDeciding implementation to allow or block navigation.

### JavaScript interaction
Use page.callJavaScript(_:arguments:contentWorld:) to evaluate scripts and capture results.

### Customization modifiers
- webViewBackForwardNavigationGestures(.enabled/.disabled)
- webViewMagnificationGestures(.enabled/.disabled)
- webViewLinkPreviews(.enabled/.disabled)
- webViewTextSelection(.enabled/.disabled)
- webViewContentBackground(.color(...))
- webViewContextMenu { actions in ... }
- webViewElementFullscreenBehavior(.enabled/.disabled)

### Advanced features
- page.snapshot(_:) to capture images.
- page.pdf(configuration:) to generate PDFs.
- page.webArchiveData() to archive content.

## Output style when using this skill
- Provide short, ordered steps.
- Include a minimal SwiftUI snippet that illustrates the pattern.
- Call out OS availability when using newer APIs.
