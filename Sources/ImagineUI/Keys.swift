public struct Keys: Hashable {
    public var rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public func hasModifier(_ key: Keys) -> Bool {
        return (rawValue & key.rawValue) == key.rawValue
    }

    public func hasModifier(_ modifier: KeyboardModifier) -> Bool {
        return (rawValue & modifier.rawValue) == modifier.rawValue
    }
}

public extension Keys {
    /// The A key.
    static let a = Keys(rawValue: 65)

    /// The add key.
    static let add = Keys(rawValue: 107)

    /// The ALT modifier key.
    static let alt = Keys(rawValue: 262144)

    /// The application key (Microsoft Natural Keyboard).
    static let apps = Keys(rawValue: 93)

    /// The ATTN key.
    static let attn = Keys(rawValue: 246)

    /// The B key.
    static let b = Keys(rawValue: 66)

    /// The BACKSPACE key.
    static let back = Keys(rawValue: 8)

    /// The browser back key (Windows 2000 or later).
    static let browserBack = Keys(rawValue: 166)

    /// The browser favorites key (Windows 2000 or later).
    static let browserFavorites = Keys(rawValue: 171)

    /// The browser forward key (Windows 2000 or later).
    static let browserForward = Keys(rawValue: 167)

    /// The browser home key (Windows 2000 or later).
    static let browserHome = Keys(rawValue: 172)

    /// The browser refresh key (Windows 2000 or later).
    static let browserRefresh = Keys(rawValue: 168)

    /// The browser search key (Windows 2000 or later).
    static let browserSearch = Keys(rawValue: 170)

    /// The browser stop key (Windows 2000 or later).
    static let browserStop = Keys(rawValue: 169)

    /// The C key.
    static let c = Keys(rawValue: 67)

    /// The CANCEL key.
    static let cancel = Keys(rawValue: 3)

    /// The CAPS LOCK key.
    static let capital = Keys(rawValue: 20)

    /// The CAPS LOCK key.
    static let capsLock = Keys(rawValue: 20)

    /// The CLEAR key.
    static let clear = Keys(rawValue: 12)

    /// The CTRL modifier key.
    static let control = Keys(rawValue: 131072)

    /// The CTRL key.
    static let controlKey = Keys(rawValue: 17)

    /// The CRSEL key.
    static let crsel = Keys(rawValue: 247)

    /// The D key.
    static let d = Keys(rawValue: 68)

    /// The 0 key.
    static let d0 = Keys(rawValue: 48)

    /// The 1 key.
    static let d1 = Keys(rawValue: 49)

    /// The 2 key.
    static let d2 = Keys(rawValue: 50)

    /// The 3 key.
    static let d3 = Keys(rawValue: 51)

    /// The 4 key.
    static let d4 = Keys(rawValue: 52)

    /// The 5 key.
    static let d5 = Keys(rawValue: 53)

    /// The 6 key.
    static let d6 = Keys(rawValue: 54)

    /// The 7 key.
    static let d7 = Keys(rawValue: 55)

    /// The 8 key.
    static let d8 = Keys(rawValue: 56)

    /// The 9 key.
    static let d9 = Keys(rawValue: 57)

    /// The decimal key.
    static let decimal = Keys(rawValue: 110)

    /// The DEL key.
    static let delete = Keys(rawValue: 46)

    /// The divide key.
    static let divide = Keys(rawValue: 111)

    /// The DOWN ARROW key.
    static let down = Keys(rawValue: 40)

    /// The E key.
    static let e = Keys(rawValue: 69)

    /// The END key.
    static let end = Keys(rawValue: 35)

    /// The ENTER key.
    static let enter = Keys(rawValue: 13)

    /// The ERASE EOF key.
    static let eraseEof = Keys(rawValue: 249)

    /// The ESC key.
    static let escape = Keys(rawValue: 27)

    /// The EXECUTE key.
    static let execute = Keys(rawValue: 43)

    /// The EXSEL key.
    static let exsel = Keys(rawValue: 248)

    /// The F key.
    static let f = Keys(rawValue: 70)

    /// The F1 key.
    static let f1 = Keys(rawValue: 112)

    /// The F10 key.
    static let f10 = Keys(rawValue: 121)

    /// The F11 key.
    static let f11 = Keys(rawValue: 122)

    /// The F12 key.
    static let f12 = Keys(rawValue: 123)

    /// The F13 key.
    static let f13 = Keys(rawValue: 124)

    /// The F14 key.
    static let f14 = Keys(rawValue: 125)

    /// The F15 key.
    static let f15 = Keys(rawValue: 126)

    /// The F16 key.
    static let f16 = Keys(rawValue: 127)

    /// The F17 key.
    static let f17 = Keys(rawValue: 128)

    /// The F18 key.
    static let f18 = Keys(rawValue: 129)

    /// The F19 key.
    static let f19 = Keys(rawValue: 130)

    /// The F2 key.
    static let f2 = Keys(rawValue: 113)

    /// The F20 key.
    static let f20 = Keys(rawValue: 131)

    /// The F21 key.
    static let f21 = Keys(rawValue: 132)

    /// The F22 key.
    static let f22 = Keys(rawValue: 133)

    /// The F23 key.
    static let f23 = Keys(rawValue: 134)

    /// The F24 key.
    static let f24 = Keys(rawValue: 135)

    /// The F3 key.
    static let f3 = Keys(rawValue: 114)

    /// The F4 key.
    static let f4 = Keys(rawValue: 115)

    /// The F5 key.
    static let f5 = Keys(rawValue: 116)

    /// The F6 key.
    static let f6 = Keys(rawValue: 117)

    /// The F7 key.
    static let f7 = Keys(rawValue: 118)

    /// The F8 key.
    static let f8 = Keys(rawValue: 119)

    /// The F9 key.
    static let f9 = Keys(rawValue: 120)

    /// The IME final mode key.
    static let finalMode = Keys(rawValue: 24)

    /// The G key.
    static let g = Keys(rawValue: 71)

    /// The H key.
    static let h = Keys(rawValue: 72)

    /// The IME Hanguel mode key. (maintained for compatibility; use HangulMode)
    static let hanguelMode = Keys(rawValue: 21)

    /// The IME Hangul mode key.
    static let hangulMode = Keys(rawValue: 21)

    /// The IME Hanja mode key.
    static let hanjaMode = Keys(rawValue: 25)

    /// The HELP key.
    static let help = Keys(rawValue: 47)

    /// The HOME key.
    static let home = Keys(rawValue: 36)

    /// The I key.
    static let i = Keys(rawValue: 73)

    /// The IME accept key, replaces IMEAceept.
    static let imeAccept = Keys(rawValue: 30)

    /// The IME accept key. Obsolete, use IMEAccept instead.
    static let imeAceept = Keys(rawValue: 30)

    /// The IME convert key.
    static let imeConvert = Keys(rawValue: 28)

    /// The IME mode change key.
    static let imeModeChange = Keys(rawValue: 31)

    /// The IME nonconvert key.
    static let imeNonconvert = Keys(rawValue: 29)

    /// The INS key.
    static let insert = Keys(rawValue: 45)

    /// The J key.
    static let j = Keys(rawValue: 74)

    /// The IME Junja mode key.
    static let junjaMode = Keys(rawValue: 23)

    /// The K key.
    static let k = Keys(rawValue: 75)

    /// The IME Kana mode key.
    static let kanaMode = Keys(rawValue: 21)

    /// The IME Kanji mode key.
    static let kanjiMode = Keys(rawValue: 25)

    /// The bitmask to extract a key code from a key value.
    static let keyCode = Keys(rawValue: 65535)

    /// The L key.
    static let l = Keys(rawValue: 76)

    /// The start application one key (Windows 2000 or later).
    static let launchApplication1 = Keys(rawValue: 182)

    /// The start application two key (Windows 2000 or later).
    static let launchApplication2 = Keys(rawValue: 183)

    /// The launch mail key (Windows 2000 or later).
    static let launchMail = Keys(rawValue: 180)

    /// The left mouse button.
    static let lButton = Keys(rawValue: 1)

    /// The left CTRL key.
    static let lControlKey = Keys(rawValue: 162)

    /// The LEFT ARROW key.
    static let left = Keys(rawValue: 37)

    /// The LINEFEED key.
    static let lineFeed = Keys(rawValue: 10)

    /// The left ALT key.
    static let lMenu = Keys(rawValue: 164)

    /// The left SHIFT key.
    static let lShiftKey = Keys(rawValue: 160)

    /// The left Windows logo key (Microsoft Natural Keyboard).
    static let lWin = Keys(rawValue: 91)

    /// The M key.
    static let m = Keys(rawValue: 77)

    /// The middle mouse button (three-button mouse).
    static let mButton = Keys(rawValue: 4)

    /// The media next track key (Windows 2000 or later).
    static let mediaNextTrack = Keys(rawValue: 176)

    /// The media play pause key (Windows 2000 or later).
    static let mediaPlayPause = Keys(rawValue: 179)

    /// The media previous track key (Windows 2000 or later).
    static let mediaPreviousTrack = Keys(rawValue: 177)

    /// The media Stop key (Windows 2000 or later).
    static let mediaStop = Keys(rawValue: 178)

    /// The ALT key.
    static let menu = Keys(rawValue: 18)

    /// The bitmask to extract modifiers from a key value.
    static let modifiers = Keys(rawValue: -65536)

    /// The multiply key.
    static let multiply = Keys(rawValue: 106)

    /// The N key.
    static let n = Keys(rawValue: 78)

    /// The PAGE DOWN key.
    static let next = Keys(rawValue: 34)

    /// A constant reserved for future use.
    static let noName = Keys(rawValue: 252)

    /// No key pressed.
    static let none = Keys(rawValue: 0)

    /// The NUM LOCK key.
    static let numLock = Keys(rawValue: 144)

    /// The 0 key on the numeric keypad.
    static let numPad0 = Keys(rawValue: 96)

    /// The 1 key on the numeric keypad.
    static let numPad1 = Keys(rawValue: 97)

    /// The 2 key on the numeric keypad.
    static let numPad2 = Keys(rawValue: 98)

    /// The 3 key on the numeric keypad.
    static let numPad3 = Keys(rawValue: 99)

    /// The 4 key on the numeric keypad.
    static let numPad4 = Keys(rawValue: 100)

    /// The 5 key on the numeric keypad.
    static let numPad5 = Keys(rawValue: 101)

    /// The 6 key on the numeric keypad.
    static let numPad6 = Keys(rawValue: 102)

    /// The 7 key on the numeric keypad.
    static let numPad7 = Keys(rawValue: 103)

    /// The 8 key on the numeric keypad.
    static let numPad8 = Keys(rawValue: 104)

    /// The 9 key on the numeric keypad.
    static let numPad9 = Keys(rawValue: 105)

    /// The O key.
    static let o = Keys(rawValue: 79)

    /// The OEM 1 key.
    static let oem1 = Keys(rawValue: 186)

    /// The OEM 102 key.
    static let oem102 = Keys(rawValue: 226)

    /// The OEM 2 key.
    static let oem2 = Keys(rawValue: 191)

    /// The OEM 3 key.
    static let oem3 = Keys(rawValue: 192)

    /// The OEM 4 key.
    static let oem4 = Keys(rawValue: 219)

    /// The OEM 5 key.
    static let oem5 = Keys(rawValue: 220)

    /// The OEM 6 key.
    static let oem6 = Keys(rawValue: 221)

    /// The OEM 7 key.
    static let oem7 = Keys(rawValue: 222)

    /// The OEM 8 key.
    static let oem8 = Keys(rawValue: 223)

    /// The OEM angle bracket or backslash key on the RT 102 key keyboard
    /// (Windows 2000 or later).
    static let oemBackslash = Keys(rawValue: 226)

    /// The CLEAR key.
    static let oemClear = Keys(rawValue: 254)

    /// The OEM close bracket key on a US standard keyboard (Windows 2000 or later).
    static let oemCloseBrackets = Keys(rawValue: 221)

    /// The OEM comma key on any country/region keyboard (Windows 2000 or later).
    static let oemcomma = Keys(rawValue: 188)

    /// The OEM minus key on any country/region keyboard (Windows 2000 or later).
    static let oemMinus = Keys(rawValue: 189)

    /// The OEM open bracket key on a US standard keyboard (Windows 2000 or later).
    static let oemOpenBrackets = Keys(rawValue: 219)

    /// The OEM period key on any country/region keyboard (Windows 2000 or later).
    static let oemPeriod = Keys(rawValue: 190)

    /// The OEM pipe key on a US standard keyboard (Windows 2000 or later).
    static let oemPipe = Keys(rawValue: 220)

    /// The OEM plus key on any country/region keyboard (Windows 2000 or later).
    static let oemplus = Keys(rawValue: 187)

    /// The OEM question mark key on a US standard keyboard (Windows 2000 or later).
    static let oemQuestion = Keys(rawValue: 191)

    /// The OEM singled/double quote key on a US standard keyboard (Windows 2000
    /// or later).
    static let oemQuotes = Keys(rawValue: 222)

    /// The OEM Semicolon key on a US standard keyboard (Windows 2000 or later).
    static let oemSemicolon = Keys(rawValue: 186)

    /// The OEM tilde key on a US standard keyboard (Windows 2000 or later).
    static let oemtilde = Keys(rawValue: 192)

    /// The P key.
    static let p = Keys(rawValue: 80)

    /// The PA1 key.
    static let pa1 = Keys(rawValue: 253)

    /// Used to pass Unicode characters as if they were keystrokes. The Packet
    /// /key value is the low word of a 32-bit virtual-key value used for
    /// non-keyboard input methods.
    static let packet = Keys(rawValue: 231)

    /// The PAGE DOWN key.
    static let pageDown = Keys(rawValue: 34)

    /// The PAGE UP key.
    static let pageUp = Keys(rawValue: 33)

    /// The PAUSE key.
    static let pause = Keys(rawValue: 19)

    /// The PLAY key.
    static let play = Keys(rawValue: 250)

    /// The PRINT key.
    static let print = Keys(rawValue: 42)

    /// The PRINT SCREEN key.
    static let printScreen = Keys(rawValue: 44)

    /// The PAGE UP key.
    static let prior = Keys(rawValue: 33)

    /// The PROCESS KEY key.
    static let processKey = Keys(rawValue: 229)

    /// The Q key.
    static let q = Keys(rawValue: 81)

    /// The R key.
    static let r = Keys(rawValue: 82)

    /// The right mouse button.
    static let rButton = Keys(rawValue: 2)

    /// The right CTRL key.
    static let rControlKey = Keys(rawValue: 163)

    /// The RETURN key.
    static let `return` = Keys(rawValue: 13)

    /// The RIGHT ARROW key.
    static let right = Keys(rawValue: 39)

    /// The right ALT key.
    static let rMenu = Keys(rawValue: 165)

    /// The right SHIFT key.
    static let rShiftKey = Keys(rawValue: 161)

    /// The right Windows logo key (Microsoft Natural Keyboard).
    static let rWin = Keys(rawValue: 92)

    /// The S key.
    static let s = Keys(rawValue: 83)

    /// The SCROLL LOCK key.
    static let scroll = Keys(rawValue: 145)

    /// The SELECT key.
    static let select = Keys(rawValue: 41)

    /// The select media key (Windows 2000 or later).
    static let selectMedia = Keys(rawValue: 181)

    /// The separator key.
    static let separator = Keys(rawValue: 108)

    /// The SHIFT modifier key.
    static let shift = Keys(rawValue: 65536)

    /// The SHIFT key.
    static let shiftKey = Keys(rawValue: 16)

    /// The computer sleep key.
    static let sleep = Keys(rawValue: 95)

    /// The PRINT SCREEN key.
    static let snapshot = Keys(rawValue: 44)

    /// The SPACEBAR key.
    static let space = Keys(rawValue: 32)

    /// The subtract key.
    static let subtract = Keys(rawValue: 109)

    /// The T key.
    static let t = Keys(rawValue: 84)

    /// The TAB key.
    static let tab = Keys(rawValue: 9)

    /// The U key.
    static let u = Keys(rawValue: 85)

    /// The UP ARROW key.
    static let up = Keys(rawValue: 38)

    /// The V key.
    static let v = Keys(rawValue: 86)

    /// The volume down key (Windows 2000 or later).
    static let volumeDown = Keys(rawValue: 174)

    /// The volume mute key (Windows 2000 or later).
    static let volumeMute = Keys(rawValue: 173)

    /// The volume up key (Windows 2000 or later).
    static let volumeUp = Keys(rawValue: 175)

    /// The W key.
    static let w = Keys(rawValue: 87)

    /// The X key.
    static let x = Keys(rawValue: 88)

    /// The first x mouse button (five-button mouse).
    static let xButton1 = Keys(rawValue: 5)

    /// The second x mouse button (five-button mouse).
    static let xButton2 = Keys(rawValue: 6)

    /// The Y key.
    static let y = Keys(rawValue: 89)

    /// The Z key.
    static let z = Keys(rawValue: 90)

    /// The ZOOM key.
    static let zoom = Keys(rawValue: 251)

    #if os(macOS)
    /// Command key (macOS only)
    static let command = Keys(rawValue: 283)
    #endif
}
