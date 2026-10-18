pragma Singleton

import QtQuick
import Quickshell
import qs.services

// Every color, size and duration in the shell. Two palettes, chosen by
// ThemeState.dark (darkman, or the toggle in the control center).
Singleton {
    id: root

    readonly property bool dark: ThemeState.dark

    // ----- glass ----------------------------------------------------------
    // Silhouette fill of every compositor-glass surface. Its alpha must stay
    // equal to ISLAND_GLASS_OPTIONS.surfaceOpacity (0.20) in
    // config/shojiwm/src/effect/island-glass.ts: ShojiWM divides by it to
    // recover the antialiased edge.
    // Neutral and nearly invisible: like macOS, the glass is clear and only
    // bends and lightly blurs what is behind it; it adds no white or black.
    readonly property real glassAlpha: 0.04
    readonly property color glassTint: Qt.rgba(0.5, 0.5, 0.5, glassAlpha)
    // Kept for popups drawn outside compositor glass (dock labels).
    readonly property color glassRim: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.45)
    // Hairlines (dividers).
    readonly property color line: dark ? Qt.rgba(1, 1, 1, 0.42) : Qt.rgba(0.15, 0.16, 0.22, 0.38)
    readonly property color lineFaint: dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0.15, 0.16, 0.22, 0.18)
    // macOS Control Center platters and controls, on the dimmed glass.
    readonly property color module: dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.24)
    readonly property color buttonOff: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.42)
    readonly property color sliderTrack: dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.34)
    // Hover / pressed / selected washes inside glass.
    readonly property color hover: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.26)
    readonly property color pressed: dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.38)
    readonly property color selected: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.32)

    // QML-side glass (lock screen, greeter): just a whisper of tint.
    readonly property color frostTint: dark ? Qt.rgba(0, 0, 0, 0.06) : Qt.rgba(1, 1, 1, 0.06)

    // ----- text -------------------------------------------------------------
    readonly property color text: dark ? "#f3f2fa" : "#262838"
    readonly property color textDim: dark ? "#b4b6c8" : "#5d6075"
    readonly property color textFaint: dark ? "#80839a" : "#8a8ca0"
    // Text straight on the wallpaper (lock clock, greeter).
    readonly property color onWallpaper: "#ffffff"

    readonly property color accent: dark ? "#0a84ff" : "#007aff"
    readonly property color accentText: "#ffffff"
    readonly property color danger: dark ? "#ff8f9c" : "#e0465c"
    readonly property color success: dark ? "#8fe3b0" : "#2fa56a"

    // ----- type -------------------------------------------------------------
    readonly property string font: "Inter"
    readonly property string fontMono: "JetBrains Mono Nerd Font"
    readonly property string iconFont: "Material Symbols Rounded"

    readonly property int textXs: 11
    readonly property int textBar: 13
    readonly property int textSm: 12
    readonly property int textMd: 13
    readonly property int textLg: 15
    readonly property int textXl: 20

    // ----- geometry ---------------------------------------------------------
    readonly property int gap: 8
    readonly property int pad: 12
    readonly property int edge: 10          // distance of bar / dock from the screen edge

    readonly property int barHeight: 32
    readonly property int barRadius: barHeight / 2
    // Where panels hanging from the menu bar start.
    readonly property int barExclusive: barHeight + 8

    readonly property int dockIcon: 52
    readonly property int dockPad: 9
    readonly property int dockHeight: dockIcon + dockPad * 2
    readonly property int dockRadius: 19
    readonly property int dockGap: 6          // dock above the bottom edge

    readonly property int panelRadius: 22
    readonly property int tileRadius: 14

    // ----- motion -----------------------------------------------------------
    readonly property int fast: 140
    readonly property int normal: 220
    readonly property int slow: 380
    // A soft spring-like curve used for every open/close.
    readonly property var emphasized: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
}
