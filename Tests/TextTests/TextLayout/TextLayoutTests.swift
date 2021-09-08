import XCTest
import Geometry

@testable import Text

class TextLayoutTests: XCTestCase {
    func testPerformance_noLineBreaks() {
        let font = makeFont(size: 20)
        
        measure {
            for _ in 0..<10 {
                _ = TextLayout(font: font, text: loremIpsumNoLineBreaks)
            }
        }
    }
    
    func testPerformance_lineBreaks() {
        let font = makeFont(size: 20)
        
        measure {
            for _ in 0..<10 {
                _ = TextLayout(font: font, text: loremIpsumLineBreaks)
            }
        }
    }
    
    func testLocationOfCharacter() {
        let sut = makeSut(text: "A string")
        
        let location = sut.locationOfCharacter(index: 2)
        
        XCTAssertEqual(location, UIVector(x: 17.978515625, y: 0.0))
    }
    
    func testLocationOfCharacterOffBounds() {
        let sut = makeSut(text: "A string")
        
        let location = sut.locationOfCharacter(index: 100)
        
        XCTAssertEqual(location, sut.locationOfCharacter(index: sut.text.count))
    }
    
    func testHitTestPoint() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(UIVector(x: 3, y: 2))
        
        XCTAssert(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 0)
        XCTAssertFalse(hitTest.isTrailing)
    }
    
    func testHitTestPoint_segmentedText() {
        var attributed = AttributedText("A string")
        attributed.addAttributes(.init(start: 3, length: 2), [
            "custom": TestAttribute()
        ])
        let sut = makeSut(attributedText: attributed)
        
        let hitTest = sut.hitTestPoint(UIVector(x: 40, y: 2))
        
        XCTAssert(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 4)
        XCTAssertTrue(hitTest.isTrailing)
    }
    
    func testHitTestPointTrailing() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(UIVector(x: 12, y: 2))
        
        XCTAssert(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 0)
        XCTAssert(hitTest.isTrailing)
    }
    
    func testHitTestPointOutsideBoxRight() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(UIVector(x: 200, y: 0))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 7)
    }
    
    func testHitTestPointOutsideBoxBelow() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(UIVector(x: 14, y: 50))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 1)
    }
    
    func testHitTestPointMultiline() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let hitTest = sut.hitTestPoint(UIVector(x: 14, y: 60))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 10)
    }
    
    func testHitTestPoint_manyLineBreaks_performance() {
        let sut = makeSut(text: loremIpsumLineBreaks)
        
        measure {
            for _ in 0..<100 {
                _ = sut.hitTestPoint(UIVector(x: 300, y: 700))
            }
        }
    }
    
    func testHitTestPoint_longLines_performance() {
        let sut = makeSut(text: loremIpsumNoLineBreaks)
        
        measure {
            for _ in 0..<100 {
                _ = sut.hitTestPoint(UIVector(x: 4000, y: 70))
            }
        }
    }
    
    func testBoundsForCharacter() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacter(at: 7)
        
        XCTAssertEqual(result, UIRectangle(x: 60.556640625, y: 0.0, width: 12.3046875, height: 27.236328125))
    }
    
    func testBoundsForCharacter_segmentedLine() {
        var attributed = AttributedText("A string Another String")
        attributed.addAttributes(.init(start: 3, length: 10), [
            "custom": TestAttribute()
        ])
        let sut = makeSut(attributedText: attributed)
        
        let result = sut.boundsForCharacter(at: 7)
        
        XCTAssertEqual(result, UIRectangle(x: 60.556640625, y: 0.0, width: 12.3046875, height: 27.236328125))
    }
    
    func testBoundsForCharacter_lineBreak() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacter(at: 8)
        
        XCTAssertEqual(result, UIRectangle(x: 72.861328125, y: 0.0, width: 12.001953125, height: 27.236328125))
    }
    
    func testBoundsForCharacter_postLineBreak() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacter(at: 9)
        
        XCTAssertEqual(result, UIRectangle(x: 0.0, y: 27.236328125, width: 12.783203125, height: 27.236328125))
    }
    
    func testBoundsForCharacters() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacters(startIndex: 5, length: 5)
        
        XCTAssertEqual(result, [
            UIRectangle(x: 43.037109375, y: 0.0, width: 5.15625, height: 27.236328125),
            UIRectangle(x: 48.193359375, y: 0.0, width: 12.36328125, height: 27.236328125),
            UIRectangle(x: 60.556640625, y: 0.0, width: 12.3046875, height: 27.236328125),
            UIRectangle(x: 72.861328125, y: 0.0, width: 12.001953125, height: 27.236328125),
            UIRectangle(x: 0.0, y: 27.236328125, width: 12.783203125, height: 27.236328125)
        ])
    }
    
    func testBoundsForCharacters_manyLineBreaks_performance() {
        let sut = makeSut(text: loremIpsumLineBreaks)
        
        measure {
            for _ in 0..<1000 {
                _ = sut.boundsForCharacters(startIndex: 300, length: 5)
            }
        }
    }
    
    func testBoundsForCharacters_longLines_performance() {
        let sut = makeSut(text: loremIpsumNoLineBreaks)
        
        measure {
            for _ in 0..<1000 {
                _ = sut.boundsForCharacters(startIndex: 300, length: 5)
            }
        }
    }
}

extension TextLayoutTests {
    func makeSut(text: String) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, text: text)
    }
    
    func makeSut(attributedText: AttributedText) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, attributedText: attributedText)
    }
    
    func makeFont(size: Float) -> Font {
        return TestFont(size: size)
    }
}

private class TestAttribute: TextAttributeType {
    func isEqual(to other: TextAttributeType) -> Bool {
        other as? TestAttribute === self
    }
}

let loremIpsumNoLineBreaks = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Faucibus pulvinar elementum integer enim neque. Adipiscing elit pellentesque habitant morbi tristique senectus et netus. Purus ut faucibus pulvinar elementum. Etiam tempor orci eu lobortis elementum. Lectus nulla at volutpat diam ut venenatis tellus in metus. Massa vitae tortor condimentum lacinia. Pharetra sit amet aliquam id diam. Sollicitudin aliquam ultrices sagittis orci. Praesent tristique magna sit amet purus gravida quis. At ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Ac feugiat sed lectus vestibulum mattis ullamcorper velit. Habitant morbi tristique senectus et netus et malesuada. Vivamus arcu felis bibendum ut tristique et egestas quis. Vestibulum morbi blandit cursus risus.

Ipsum nunc aliquet bibendum enim facilisis gravida neque convallis a. Imperdiet sed euismod nisi porta lorem mollis aliquam. Mattis nunc sed blandit libero. At in tellus integer feugiat scelerisque varius morbi. Amet massa vitae tortor condimentum lacinia quis. Viverra adipiscing at in tellus integer feugiat scelerisque varius morbi. Dis parturient montes nascetur ridiculus mus mauris vitae. Tortor vitae purus faucibus ornare suspendisse sed nisi. Commodo sed egestas egestas fringilla phasellus. Lacus vel facilisis volutpat est velit egestas dui id ornare. Eget est lorem ipsum dolor sit amet consectetur adipiscing. At risus viverra adipiscing at in tellus integer feugiat. Sem viverra aliquet eget sit amet tellus. Ut lectus arcu bibendum at varius vel pharetra vel. Ultrices in iaculis nunc sed augue. Urna molestie at elementum eu facilisis sed odio morbi quis. Justo donec enim diam vulputate ut pharetra sit amet.

Elit pellentesque habitant morbi tristique senectus et netus et. Imperdiet proin fermentum leo vel orci. Sed cras ornare arcu dui vivamus. Et ultrices neque ornare aenean. Diam donec adipiscing tristique risus. Elementum curabitur vitae nunc sed velit dignissim sodales ut eu. Volutpat maecenas volutpat blandit aliquam. Quam elementum pulvinar etiam non quam. Semper auctor neque vitae tempus quam pellentesque. Eget nullam non nisi est sit amet. Odio aenean sed adipiscing diam donec adipiscing tristique risus nec. Enim lobortis scelerisque fermentum dui faucibus in ornare. Purus faucibus ornare suspendisse sed nisi lacus sed viverra tellus. Et sollicitudin ac orci phasellus egestas tellus. Vitae sapien pellentesque habitant morbi tristique senectus. Quis imperdiet massa tincidunt nunc. Donec et odio pellentesque diam. Purus semper eget duis at tellus at. Eget nullam non nisi est sit amet facilisis magna.

Dui ut ornare lectus sit. Elit ut aliquam purus sit amet luctus venenatis lectus magna. Sit amet dictum sit amet justo donec enim diam. Turpis egestas sed tempus urna et. Posuere urna nec tincidunt praesent semper feugiat nibh. Lorem mollis aliquam ut porttitor leo a diam sollicitudin. Augue ut lectus arcu bibendum. Pharetra pharetra massa massa ultricies mi quis hendrerit. Consequat ac felis donec et odio pellentesque diam. Ultrices mi tempus imperdiet nulla malesuada pellentesque elit eget. Cras fermentum odio eu feugiat pretium nibh ipsum. Nunc mi ipsum faucibus vitae aliquet nec ullamcorper sit amet.

Fringilla urna porttitor rhoncus dolor purus. Egestas purus viverra accumsan in nisl nisi scelerisque. Amet luctus venenatis lectus magna fringilla urna porttitor rhoncus dolor. Pharetra pharetra massa massa ultricies mi. Mattis pellentesque id nibh tortor id aliquet. Eget arcu dictum varius duis at consectetur. Pellentesque id nibh tortor id. Vestibulum lectus mauris ultrices eros in cursus turpis massa tincidunt. Morbi tempus iaculis urna id volutpat. Condimentum lacinia quis vel eros donec ac. Fermentum leo vel orci porta. Malesuada pellentesque elit eget gravida cum sociis. Ullamcorper malesuada proin libero nunc consequat interdum.
"""

let loremIpsumLineBreaks = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Faucibus pulvinar elementum integer
enim neque. Adipiscing elit pellentesque habitant morbi tristique senectus et
netus. Purus ut faucibus pulvinar elementum. Etiam tempor orci eu lobortis
elementum. Lectus nulla at volutpat diam ut venenatis tellus in metus. Massa
vitae tortor condimentum lacinia. Pharetra sit amet aliquam id diam.
Sollicitudin aliquam ultrices sagittis orci. Praesent tristique magna sit amet
purus gravida quis. At ultrices mi tempus imperdiet nulla malesuada pellentesque
elit. Ac feugiat sed lectus vestibulum mattis ullamcorper velit. Habitant morbi
tristique senectus et netus et malesuada. Vivamus arcu felis bibendum ut
tristique et egestas quis. Vestibulum morbi blandit cursus risus.

Ipsum nunc aliquet bibendum enim facilisis gravida neque convallis a. Imperdiet
sed euismod nisi porta lorem mollis aliquam. Mattis nunc sed blandit libero. At
in tellus integer feugiat scelerisque varius morbi. Amet massa vitae tortor
condimentum lacinia quis. Viverra adipiscing at in tellus integer feugiat
scelerisque varius morbi. Dis parturient montes nascetur ridiculus mus mauris
vitae. Tortor vitae purus faucibus ornare suspendisse sed nisi. Commodo sed
egestas egestas fringilla phasellus. Lacus vel facilisis volutpat est velit
egestas dui id ornare. Eget est lorem ipsum dolor sit amet consectetur
adipiscing. At risus viverra adipiscing at in tellus integer feugiat. Sem
viverra aliquet eget sit amet tellus. Ut lectus arcu bibendum at varius vel
pharetra vel. Ultrices in iaculis nunc sed augue. Urna molestie at elementum eu
facilisis sed odio morbi quis. Justo donec enim diam vulputate ut pharetra sit
amet.

Elit pellentesque habitant morbi tristique senectus et netus et. Imperdiet proin
fermentum leo vel orci. Sed cras ornare arcu dui vivamus. Et ultrices neque
ornare aenean. Diam donec adipiscing tristique risus. Elementum curabitur vitae
nunc sed velit dignissim sodales ut eu. Volutpat maecenas volutpat blandit
aliquam. Quam elementum pulvinar etiam non quam. Semper auctor neque vitae
tempus quam pellentesque. Eget nullam non nisi est sit amet. Odio aenean sed
adipiscing diam donec adipiscing tristique risus nec. Enim lobortis scelerisque
fermentum dui faucibus in ornare. Purus faucibus ornare suspendisse sed nisi
lacus sed viverra tellus. Et sollicitudin ac orci phasellus egestas tellus.
Vitae sapien pellentesque habitant morbi tristique senectus. Quis imperdiet
massa tincidunt nunc. Donec et odio pellentesque diam. Purus semper eget duis at
tellus at. Eget nullam non nisi est sit amet facilisis magna.

Dui ut ornare lectus sit. Elit ut aliquam purus sit amet luctus venenatis lectus
 magna. Sit amet dictum sit amet justo donec enim diam. Turpis egestas sed
tempus urna et. Posuere urna nec tincidunt praesent semper feugiat nibh. Lorem
mollis aliquam ut porttitor leo a diam sollicitudin. Augue ut lectus arcu
bibendum. Pharetra pharetra massa massa ultricies mi quis hendrerit. Consequat
ac felis donec et odio pellentesque diam. Ultrices mi tempus imperdiet nulla
malesuada pellentesque elit eget. Cras fermentum odio eu feugiat pretium nibh
ipsum. Nunc mi ipsum faucibus vitae aliquet nec ullamcorper sit amet.

Fringilla urna porttitor rhoncus dolor purus. Egestas purus viverra accumsan in
nisl nisi scelerisque. Amet luctus venenatis lectus magna fringilla urna
porttitor rhoncus dolor. Pharetra pharetra massa massa ultricies mi. Mattis
pellentesque id nibh tortor id aliquet. Eget arcu dictum varius duis at
consectetur. Pellentesque id nibh tortor id. Vestibulum lectus mauris ultrices
eros in cursus turpis massa tincidunt. Morbi tempus iaculis urna id volutpat.
Condimentum lacinia quis vel eros donec ac. Fermentum leo vel orci porta.
Malesuada pellentesque elit eget gravida cum sociis. Ullamcorper malesuada proin
libero nunc consequat interdum.
"""
