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
    readonly property var wifiStrength: [0xF091F, 0xF0922, 0xF0925, 0xF0928].map(glyph)
    readonly property string check: glyph(0xF012C)
    readonly property string refresh: glyph(0xF0450)
    readonly property string headphones: glyph(0xF02CB)
    readonly property string speaker: glyph(0xF04C3)
    readonly property string keyboard: glyph(0xF030C)
    readonly property string mouse: glyph(0xF037D)
    readonly property string phone: glyph(0xF03F2)
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
    readonly property string brightness: glyph(0xF00DF)
    readonly property string microphone: glyph(0xF036C)
    readonly property string microphoneOff: glyph(0xF036D)
    readonly property string bell: glyph(0xF009A)
    readonly property string bellOff: glyph(0xF009B)
    readonly property string search: glyph(0xF0349)
    readonly property string application: glyph(0xF0614)
    readonly property string calculator: glyph(0xF00EC)
    readonly property string file: glyph(0xF0214)
    readonly property string palette: glyph(0xF03D8)
    readonly property string fontIcon: glyph(0xF06D6)
    readonly property string contrast: glyph(0xF1395)
    readonly property string clipboard: glyph(0xF014C)
    readonly property string lock: glyph(0xF033E)
    readonly property string sleep: glyph(0xF04B2)
    readonly property string restart: glyph(0xF0709)
    readonly property string power: glyph(0xF0425)
    readonly property string logout: glyph(0xF0343)
    readonly property string cpu: glyph(0xF0EE0)
    readonly property string memory: glyph(0xF035B)
    readonly property string temperature: glyph(0xF050F)
    readonly property string gpu: glyph(0xF08AE)
}
