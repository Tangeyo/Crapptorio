import SwiftUI

struct ContentView: View {
    @ObservedObject var gameState = GameState()
    @State private var selectedTileType: TileTypeSelection = .factory  //track the current tile type to place
    
    //enum to manage tile selection
    enum TileTypeSelection {
        case factory
        case conveyorRight
        case conveyorLeft
        case conveyorUp
        case conveyorDown
        case miner
    }
    
    var body: some View {
        VStack {
            //create a grid for the game to be played on
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 1) {
                    ForEach(0..<gameState.grid.count, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0..<gameState.grid[row].count, id: \.self) { col in
                                TileView(tile: gameState.grid[row][col])
                                    .onTapGesture {
                                        //place a tile based on the selected type
                                        placeTile(row: row, col: col)
                                    }
                            }
                        }
                    }
                }
            }
            .padding()
            
            //buttons for each of the tiles the user can select to play as + debug statements
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        selectedTileType = .factory
                        print("Selected tile type: Factory")
                    }) {
                        Text("Factory")
                            .padding()
                            .background(selectedTileType == .factory ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTileType = .miner
                        print("Selected tile type: Miner")
                    }) {
                        Text("Miner")
                            .padding()
                            .background(selectedTileType == .miner ? Color.yellow.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    Button(action: {
                        selectedTileType = .conveyorRight
                        print("Selected tile type: Conveyor Right")
                    }) {
                        Text("→")
                            .padding()
                            .background(selectedTileType == .conveyorRight ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTileType = .conveyorLeft
                        print("Selected tile type: Conveyor Left")
                    }) {
                        Text("←")
                            .padding()
                            .background(selectedTileType == .conveyorLeft ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTileType = .conveyorUp
                        print("Selected tile type: Conveyor Up")
                    }) {
                        Text("↑")
                            .padding()
                            .background(selectedTileType == .conveyorUp ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTileType = .conveyorDown
                        print("Selected tile type: Conveyor Down")
                    }) {
                        Text("↓")
                            .padding()
                            .background(selectedTileType == .conveyorDown ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                //buttons for actions
                HStack {
                    Button(action: {
                        gameState.toggleProcessing() //correct method to toggle processing
                        print("Start Processing has been toggled")
                    }) {
                        Text(gameState.isProcessing ? "Stop Processing" : "Start Processing") //updates text dynamically
                            .padding()
                            .background(gameState.isProcessing ? Color.red : Color.green) //changes color to indicate state
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        rerollGrid()
                        print("Grid has been rerolled")
                    }) {
                        Text("Reroll Grid")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
    
    //function to place a tile based on the selected type
    private func placeTile(row: Int, col: Int) {
        switch selectedTileType {
        case .factory:
            gameState.placeFactory(at: row, col: col)
        case .conveyorRight:
            gameState.placeConveyor(at: row, col: col, direction: .right)
        case .conveyorLeft:
            gameState.placeConveyor(at: row, col: col, direction: .left)
        case .conveyorUp:
            gameState.placeConveyor(at: row, col: col, direction: .up)
        case .conveyorDown:
            gameState.placeConveyor(at: row, col: col, direction: .down)
        case .miner:
            gameState.placeMiner(at: row, col: col)
        }
    }
    
    //function to reroll the grid to all empty tiles and regenerate resource clusters
    private func rerollGrid() {
        for row in 0..<gameState.grid.count {
            for col in 0..<gameState.grid[row].count {
                gameState.grid[row][col] = Tile(type: .empty, resourceCount: 0)
            }
        }
        gameState.spawnResourceClusters()  //regenerate resource clusters after reroll
    }
}
