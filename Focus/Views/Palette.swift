import SwiftUI

struct MyColor: Identifiable {
    let id: Int
    let name: String
    let color: NSColor
    
    init(_ name: String, _ color: NSColor) {
        self.color = color
        self.id = color.hashValue
        self.name = name
    }
}

let nsColors: [(String, NSColor)] = [("black", .black), ("darkGray", .darkGray), ("lightGray", .lightGray), ("white", .white), ("gray", .gray), ("red", .red), ("green", .green), ("blue", .blue), ("cyan", .cyan), ("yellow", .yellow), ("magenta", .magenta), ("orange", .orange), ("purple", .purple), ("brown", .brown), ("clear", .clear), ("labelColor", .labelColor), ("secondaryLabelColor", .secondaryLabelColor), ("tertiaryLabelColor", .tertiaryLabelColor), ("quaternaryLabelColor", .quaternaryLabelColor), ("linkColor", .linkColor), ("placeholderTextColor", .placeholderTextColor), ("windowFrameTextColor", .windowFrameTextColor), ("selectedMenuItemTextColor", .selectedMenuItemTextColor), ("alternateSelectedControlTextColor", .alternateSelectedControlTextColor), ("headerTextColor", .headerTextColor), ("separatorColor", .separatorColor), ("gridColor", .gridColor), ("windowBackgroundColor", .windowBackgroundColor), ("underPageBackgroundColor", .underPageBackgroundColor), ("controlBackgroundColor", .controlBackgroundColor), ("selectedContentBackgroundColor", .selectedContentBackgroundColor), ("unemphasizedSelectedContentBackgroundColor", .unemphasizedSelectedContentBackgroundColor), ("findHighlightColor", .findHighlightColor), ("textColor", .textColor), ("textBackgroundColor", .textBackgroundColor), ("selectedTextColor", .selectedTextColor), ("selectedTextBackgroundColor", .selectedTextBackgroundColor), ("unemphasizedSelectedTextBackgroundColor", .unemphasizedSelectedTextBackgroundColor), ("unemphasizedSelectedTextColor", .unemphasizedSelectedTextColor), ("controlColor", .controlColor), ("controlTextColor", .controlTextColor), ("selectedControlColor", .selectedControlColor), ("selectedControlTextColor", .selectedControlTextColor), ("disabledControlTextColor", .disabledControlTextColor), ("keyboardFocusIndicatorColor", .keyboardFocusIndicatorColor), ("scrubberTexturedBackground", .scrubberTexturedBackground), ("systemRed", .systemRed), ("systemGreen", .systemGreen), ("systemBlue", .systemBlue), ("systemOrange", .systemOrange), ("systemYellow", .systemYellow), ("systemBrown", .systemBrown), ("systemPink", .systemPink), ("systemPurple", .systemPurple), ("systemGray", .systemGray), ("systemTeal", .systemTeal), ("systemIndigo", .systemIndigo), ("controlAccentColor", .controlAccentColor), ("highlightColor", .highlightColor), ("shadowColor", .shadowColor)]

let colors: [MyColor] = nsColors.map({ MyColor($0, $1) })

struct ColorPalette: View {
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(colors) { color in
                HStack {
                    Color(color.color).frame(width: 10, height: 10)
                    Text("\(color.name)")
                }
            }
        }.padding(10)
    }
}

struct FontPalette: View {
    let text = "The tao that can be spoken is not the eternal Tao"
    
    var body: some View {
        VStack {
        Text(text).font(.largeTitle)
        Text(text).font(.title)
        Text(text).font(.headline)
        Text(text).font(.subheadline)
        Text(text).font(.body)
        Text(text).font(.callout)
        Text(text).font(.caption)
        Text(text).font(.footnote)
        }
    }
}

struct Palette_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ColorPalette()
            FontPalette()
        }
    }
}
