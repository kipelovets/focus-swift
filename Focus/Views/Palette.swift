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

struct Palette: View {
    
    
    var body: some View {
        VStack {
            ForEach(colors) { color in
                HStack {
                    Color(color.color).frame(width: 10, height: 10)
                    Text("\(color.name)")
                }
            }
        }
    }
}

struct Palette_Previews: PreviewProvider {
    static var previews: some View {
        Palette()
    }
}
