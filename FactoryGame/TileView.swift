import SwiftUI

struct TileView: View {
    var tile: Tile
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color(for: tile.type))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(symbol(for: tile.type))
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                )

            if tile.resourceCount > 0 {
                Text("\(tile.resourceCount)")
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(5)
                    .offset(x: 0, y: 18)
            }

            if case .factory = tile.type {
                Text("\(tile.processedCount)")
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(5)
                    .offset(x: 0, y: -18)
            }
        }
    }
    
    //return the appropriate color for each tile type
    private func color(for type: TileType) -> Color {
        switch type {
        case .empty:
            return Color.gray
        case .factory:
            return Color.blue
        case .conveyor:
            return Color.green
        case .resource:
            return Color.orange
        case .processed:
            return Color.purple
        case .miner:
            return Color.yellow
        }
    }
    
    //set the symbols for each tile type
    private func symbol(for type: TileType) -> String {
        switch type {
        case .empty:
            return ""
        case .factory:
            return "🏭"
        case let .conveyor(direction):
            return direction.arrow
        case .resource:
            return "🪨"
        case .processed:
            return "⚙️"
        case .miner:
            return "⛏️"
        }
    }
}
