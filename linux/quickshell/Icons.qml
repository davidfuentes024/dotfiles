pragma Singleton

import QtQuick
import Quickshell

// Nerd Font (Material Design) glyphs, by code point so the source stays readable
Singleton {
    function glyph(codePoint) { return String.fromCodePoint(codePoint); }

    readonly property string plus: glyph(0xF0415)
    readonly property string ip: glyph(0xF0A60)
    readonly property string wifi: glyph(0xF05A9)
    readonly property string wifiOff: glyph(0xF05AA)
    readonly property string ethernet: glyph(0xF0200)
    readonly property string bluetooth: glyph(0xF00AF)
    readonly property string bluetoothConnected: glyph(0xF00B1)
    readonly property string bluetoothOff: glyph(0xF00B2)
    readonly property string volumeHigh: glyph(0xF057E)
    readonly property string volumeMedium: glyph(0xF0580)
    readonly property string volumeLow: glyph(0xF057F)
    readonly property string volumeMute: glyph(0xF075F)
    readonly property string batteryCharging: glyph(0xF0084)
    // battery 10%..100% in steps of 10
    readonly property var batteryLevels: [0xF007A, 0xF007B, 0xF007C, 0xF007D, 0xF007E,
                                          0xF007F, 0xF0080, 0xF0081, 0xF0082, 0xF0079].map(glyph)
    readonly property string powerSaver: glyph(0xF032A)
    readonly property string powerBalanced: glyph(0xF05D1)
    readonly property string powerPerformance: glyph(0xF04C5)
    readonly property string cpu: glyph(0xF0EE0)
    readonly property string memory: glyph(0xF035B)
    readonly property string temperature: glyph(0xF050F)
    readonly property string gpu: glyph(0xF08AE)
}
