import Cocoa
import ImagineUI

extension TestView {
    func makeKeyboardEventArgs(_ event: NSEvent) -> KeyEventArgs {
        let key = convertKeyCode(event.keyCode)
        let modifier = convertModifiers(event.modifierFlags)

        return KeyEventArgs(keyCode: key, keyChar: event.characters, modifiers: modifier)
    }

    private func convertModifiers(_ modifier: NSEvent.ModifierFlags) -> KeyboardModifier {
        var output = KeyboardModifier.none

        if modifier.contains(.shift) {
            output.formUnion(.shift)
        }
        if modifier.contains(.control) {
            output.formUnion(.control)
        }
        if modifier.contains(.command) {
            output.formUnion(.command)
        }
        if modifier.contains(.option) {
            output.formUnion(.option)
        }
        if modifier.contains(.numericPad) {
            output.formUnion(.numericPad)
        }

        return output
    }

    private func convertKeyCode(_ keyCode: UInt16) -> Keys {
        guard let key = KeyCodes(rawValue: keyCode) else {
            return .none
        }

        switch key {
        case .space:
            return .space
        case .returnKey:
            return .return
        case .keypadEnter:
            return .enter
        case .escape:
            return .escape
        case .delete:
            return .back
        case .forwardDelete:
            return .delete
        case .shift:
            return .shiftKey
        case .command:
            return .command
        case .leftArrow:
            return .left
        case .rightArrow:
            return .right
        case .downArrow:
            return .down
        case .upArrow:
            return .up
        case .a:
            return .a
        case .b:
            return .b
        case .c:
            return .c
        case .d:
            return .d
        case .e:
            return .e
        case .f:
            return .f
        case .g:
            return .g
        case .h:
            return .h
        case .i:
            return .i
        case .j:
            return .j
        case .k:
            return .k
        case .l:
            return .l
        case .m:
            return .m
        case .n:
            return .n
        case .o:
            return .o
        case .p:
            return .p
        case .q:
            return .q
        case .r:
            return .r
        case .s:
            return .s
        case .t:
            return .t
        case .u:
            return .u
        case .v:
            return .v
        case .w:
            return .w
        case .x:
            return .x
        case .y:
            return .y
        case .z:
            return .z
        case .d0:
            return .d0
        case .d1:
            return .d1
        case .d2:
            return .d2
        case .d3:
            return .d3
        case .d4:
            return .d4
        case .d5:
            return .d5
        case .d6:
            return .d6
        case .d7:
            return .d7
        case .d8:
            return .d8
        case .d9:
            return .d9
        case .keypad0:
            return .d0
        case .keypad1:
            return .d1
        case .keypad2:
            return .d2
        case .keypad3:
            return .d3
        case .keypad4:
            return .d4
        case .keypad5:
            return .d5
        case .keypad6:
            return .d6
        case .keypad7:
            return .d7
        case .keypad8:
            return .d8
        case .keypad9:
            return .d9
        case .minus:
            return .oemMinus
        case .leftBracket:
            return .oemOpenBrackets
        case .rightBracket:
            return .oemCloseBrackets
        case .semicolon:
            return .oemSemicolon
        case .quote:
            return .oemQuotes
        case .comma:
            return .oemcomma
        case .period:
            return .oemPeriod
        case .backslash:
            return .oemBackslash
        case .keypadMultiply:
            return .multiply
        case .keypadPlus:
            return .oemplus
        case .keypadDivide:
            return .divide
        case .keypadMinus:
            return .oemMinus
        case .tab:
            return .tab
        case .capsLock:
            return .capsLock
        case .control:
            return .control
        case .rightShift:
            return .rShiftKey
        case .rightControl:
            return .rControlKey
        case .volumeUp:
            return .volumeUp
        case .volumeDown:
            return .volumeDown
        case .mute:
            return .volumeMute
        case .f1:
            return .f1
        case .f2:
            return .f2
        case .f3:
            return .f3
        case .f4:
            return .f4
        case .f5:
            return .f5
        case .f6:
            return .f6
        case .f7:
            return .f7
        case .f8:
            return .f8
        case .f9:
            return .f9
        case .f10:
            return .f10
        case .f11:
            return .f11
        case .f12:
            return .f12
        case .f13:
            return .f13
        case .f14:
            return .f14
        case .f15:
            return .f15
        case .f16:
            return .f16
        case .f17:
            return .f17
        case .f18:
            return .f18
        case .f19:
            return .f19
        case .f20:
            return .f20
        case .home:
            return .home
        case .end:
            return .end
        case .pageUp:
            return .pageUp
        case .pageDown:
            return .pageDown
            
        default:
            return .none
        }
    }
}

enum KeyCodes: UInt16 {
    // Digit
    case d0 = 0x1D
    case d1 = 0x12
    case d2 = 0x13
    case d3 = 0x14
    case d4 = 0x15
    case d5 = 0x17
    case d6 = 0x16
    case d7 = 0x1A
    case d8 = 0x1C
    case d9 = 0x19
    
    // Alphabet
    case a = 0x0
    case b = 0xB
    case c = 0x8
    case d = 0x2
    case e = 0xE
    case f = 0x3
    case g = 0x5
    case h = 0x4
    case i = 0x22
    case j = 0x26
    case k = 0x28
    case l = 0x25
    case m = 0x2E
    case n = 0x2D
    case o = 0x1F
    case p = 0x23
    case q = 0xC
    case r = 0xF
    case s = 0x1
    case t = 0x11
    case u = 0x20
    case v = 0x9
    case w = 0xD
    case x = 0x7
    case y = 0x10
    case z = 0x6
    
    // Signs
    case sectionSign = 0xA
    case grave = 0x32
    case minus = 0x1B
    case equal = 0x18
    case leftBracket = 0x21
    case rightBracket = 0x1E
    case semicolon = 0x29
    case quote = 0x27
    case comma = 0x2B
    case period = 0x2F
    case slash = 0x2C
    case backslash = 0x2A
    
    // Keypad
    case keypad0 = 0x52
    case keypad1 = 0x53
    case keypad2 = 0x54
    case keypad3 = 0x55
    case keypad4 = 0x56
    case keypad5 = 0x57
    case keypad6 = 0x58
    case keypad7 = 0x59
    case keypad8 = 0x5B
    case keypad9 = 0x5C
    case keypadDecimal = 0x41
    case keypadMultiply = 0x43
    case keypadPlus = 0x45
    case keypadDivide = 0x4B
    case keypadMinus = 0x4E
    case keypadEquals = 0x51
    case keypadClear = 0x47
    case keypadEnter = 0x4C
    
    // Special keys
    case space = 0x31
    case returnKey = 0x24
    case tab = 0x30
    case delete = 0x33
    case forwardDelete = 0x75
    case linefeed = 0x34
    case escape = 0x35
    case command = 0x37
    case shift = 0x38
    case capsLock = 0x39
    case option = 0x3A
    case control = 0x3B
    case rightShift = 0x3C
    case rightOption = 0x3D
    case rightControl = 0x3E
    case function = 0x3F
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
    case helpOrInsert = 0x72
    
    // F- keys
    case f1 = 0x7A
    case f2 = 0x78
    case f3 = 0x63
    case f4 = 0x76
    case f5 = 0x60
    case f6 = 0x61
    case f7 = 0x62
    case f8 = 0x64
    case f9 = 0x65
    case f10 = 0x6D
    case f11 = 0x67
    case f12 = 0x6F
    case f13 = 0x69
    case f14 = 0x6B
    case f15 = 0x71
    case f16 = 0x6A
    case f17 = 0x40
    case f18 = 0x4F
    case f19 = 0x50
    case f20 = 0x5A
    
    // Navigation
    case home = 0x73
    case end = 0x77
    case pageUp = 0x74
    case pageDown = 0x79
    
    // Arrows
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E
}
