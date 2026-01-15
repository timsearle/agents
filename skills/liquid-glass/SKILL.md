---
name: liquid-glass
description: Definitive guidance for adopting Apple's Liquid Glass design language and SwiftUI/UIKit implementation patterns.
compatibility: iOS/iPadOS/macOS (Liquid Glass-era SDKs); SwiftUI-first; UIKit/AppKit notes included.
allowed-tools: Read
metadata:
  author: timsearle
  version: "2.0"
---

# Liquid Glass (Apple) adoption skill

Use this skill when the user asks for Liquid Glass, glassEffect, GlassEffectContainer, glass buttons, floating toolbars/tab bars, translucent navigation layers, or "new Apple design system".

## Core rule (do not violate)

Liquid Glass belongs to the navigation/controls layer floating above content, not the content layer itself.
- Use for: toolbars, navigation bars, tab bars, floating control clusters, sheets/popovers/menus.
- Avoid for: lists, tables, primary reading surfaces, media content, and stacked glass-on-glass.

## Sources of truth (use these first)

Official Apple docs (authoritative for names/availability/behavior):
- Liquid Glass overview: https://docs.developer.apple.com/documentation/technologyoverviews/liquid-glass
- Adopting Liquid Glass: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
- Applying Liquid Glass to custom views: https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views
- Landmarks (Liquid Glass): https://developer.apple.com/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass
- View.glassEffect: https://developer.apple.com/documentation/SwiftUI/View/glassEffect(_:in:isEnabled:)
- GlassEffectContainer: https://developer.apple.com/documentation/SwiftUI/GlassEffectContainer
- GlassEffectTransition: https://developer.apple.com/documentation/SwiftUI/GlassEffectTransition
- GlassButtonStyle: https://developer.apple.com/documentation/SwiftUI/GlassButtonStyle
- Toolbars: https://developer.apple.com/documentation/SwiftUI/Toolbars
- ToolbarSpacer: https://developer.apple.com/documentation/SwiftUI/ToolbarSpacer
- SearchToolbarBehavior: https://developer.apple.com/documentation/SwiftUI/SearchToolbarBehavior
- DefaultToolbarItem: https://developer.apple.com/documentation/SwiftUI/DefaultToolbarItem
- ToolbarItemPlacement: https://developer.apple.com/documentation/SwiftUI/ToolbarItemPlacement
- CustomizableToolbarContent: https://developer.apple.com/documentation/SwiftUI/CustomizableToolbarContent

Community reference (secondary):
- LiquidGlassReference: https://github.com/conorluddy/LiquidGlassReference

## SwiftUI implementation (primary path)

### 1) Prefer automatic adoption
Use standard SwiftUI structures (NavigationStack, TabView, toolbars, sheets) and remove custom backgrounds that block the system glass.
- Avoid heavy .toolbarBackground or .presentationBackground overrides unless you are intentionally opting out.

### 2) Apply glass to custom controls
Use glassEffect for custom floating controls; apply after other visual modifiers.

```swift
Text("Hello")
    .font(.title)
    .padding()
    .glassEffect(.regular.tint(.orange).interactive())

Text("Badge")
    .padding()
    .glassEffect(in: .rect(cornerRadius: 16))
```

Notes:
- .regular is the default style.
- Use .tint(...) to signal prominence.
- Use .interactive() when the control should react to touch/pointer input.

### 3) Group related glass elements
When multiple elements should blend or morph, wrap them in GlassEffectContainer.

```swift
GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "scribble.variable")
            .frame(width: 80, height: 80)
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 80, height: 80)
            .glassEffect()
    }
}
```

- Smaller spacing -> elements must be closer to merge; larger spacing -> merge from farther apart.
- Avoid separate glass elements sampling each other; use a container.

### 4) Unions and morphing transitions
Use union IDs for dynamic layouts and glassEffectID for morphing transitions.

```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 20) {
    HStack(spacing: 20) {
        ForEach(items.indices, id: \.self) { index in
            Image(systemName: items[index])
                .frame(width: 80, height: 80)
                .glassEffect()
                .glassEffectUnion(id: index < 2 ? "left" : "right", namespace: namespace)
                .glassEffectID(items[index], in: namespace)
        }
    }
}
```

- Animate hierarchy changes (withAnimation) to trigger morphing.
- Use GlassEffectTransition when you need explicit transition behavior.

### 5) Glass buttons
SwiftUI provides standard styles:

```swift
Button("Action") { }
    .buttonStyle(.glass)

Button("Primary") { }
    .buttonStyle(.glassProminent)
```

### 6) Background extension effects
Use scrollExtensionMode to extend scroll content beneath a sidebar or inspector:

```swift
ScrollView(.horizontal) { ... }
    .scrollExtensionMode(.underSidebar)
```

## Toolbars and navigation (Liquid Glass era)

### Grouping and shared backgrounds
- Toolbars adopt Liquid Glass automatically; items in the same group share one glass background.
- Group related actions together; separate groups using fixed spacers.
- Prefer icon-only controls with accessibility labels; do not mix text and icons in the same shared background group.

```swift
.toolbar(id: "main-toolbar") {
    ToolbarItem(id: "tag") { TagButton() }
    ToolbarItem(id: "share") { ShareButton() }
    ToolbarSpacer(.fixed)
    ToolbarItem(id: "more") { MoreButton() }
}
```

### Search and placement
- Minimize search to save space: .searchToolbarBehavior(.minimize)
- Reposition search: DefaultToolbarItem(kind: .search, placement: .bottomBar)

### Opt out of shared background for a specific item
```swift
ToolbarItem(id: "build-status", placement: .principal) {
    BuildStatus()
}
.sharedBackgroundVisibility(.hidden)
```

### New placements + transitions
- Use .largeSubtitle placement for custom subtitle content.
- Use matchedTransitionSource on toolbar items for coordinated transitions.

### Hiding items
Hide the toolbar item itself (not the inner view):

```swift
ToolbarItem(id: "download") { DownloadButton() }
    .hidden(isHidden)
```

## UIKit/AppKit guidance (when SwiftUI is not possible)

Use Liquid Glass-era UIKit APIs when available; gate with availability checks.

### Basic glass effect
```swift
let glassEffect = UIGlassEffect()
glassEffect.tintColor = UIColor.systemBlue.withAlphaComponent(0.3)
glassEffect.isInteractive = true

let view = UIVisualEffectView(effect: glassEffect)
view.layer.cornerRadius = 20
view.clipsToBounds = true
```

### Container blending
```swift
let container = UIGlassContainerEffect()
container.spacing = 40

let containerView = UIVisualEffectView(effect: container)
```

### Scroll edge effects
```swift
scrollView.topEdgeEffect.style = .automatic
scrollView.bottomEdgeEffect.style = .hard
```

Use UIScrollEdgeElementContainerInteraction to let overlay views influence edge effect shapes.

### Toolbar items
- UIBarButtonItem supports hiding the shared background via hidesSharedBackground.

If Liquid Glass APIs are unavailable on a target OS, fall back to system materials (UIBlurEffect + standard bars) instead of custom glass.

## Accessibility requirements
- Assume Reduce Transparency, Increase Contrast, and Reduce Motion.
- Prefer system components so the OS can adapt automatically.
- Ensure text over glass meets contrast requirements.

## Performance requirements
- Glass is GPU-expensive; prefer fewer, larger surfaces.
- Group related controls in GlassEffectContainer.
- Avoid constant animations; allow glass to rest.

## Review checklist
1. Glass limited to navigation/controls, not content.
2. No glass-on-glass stacking.
3. No custom backgrounds blocking system glass.
4. Related controls grouped in GlassEffectContainer.
5. Tint used sparingly and semantically.
6. Accessibility settings accounted for.
7. Performance acceptable on low-end devices.

## Output style when using this skill
- Start with a short "what to change" list.
- Provide minimal SwiftUI snippets to clarify.
- Call out API availability and link Apple docs for exact signatures.
