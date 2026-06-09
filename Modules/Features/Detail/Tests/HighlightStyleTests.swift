import Testing
import DetailDomain

struct HighlightStyleTests {
    @Test
    func rawValueMatchesJSBridgeContract() {
        #expect(HighlightStyle.yellow.rawValue == "yellow")
        #expect(HighlightStyle.orange.rawValue == "orange")
        #expect(HighlightStyle.pink.rawValue == "pink")
        #expect(HighlightStyle.green.rawValue == "green")
        #expect(HighlightStyle.blue.rawValue == "blue")
        #expect(HighlightStyle.underline.rawValue == "underline")
    }

    @Test
    func roundTripsThroughRawValue() {
        for style in HighlightStyle.allCases {
            #expect(HighlightStyle(rawValue: style.rawValue) == style)
        }
    }

    @Test
    func unknownRawValueReturnsNil() {
        #expect(HighlightStyle(rawValue: "rainbow") == nil)
        #expect(HighlightStyle(rawValue: "") == nil)
    }
}
