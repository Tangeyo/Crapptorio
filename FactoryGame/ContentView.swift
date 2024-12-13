import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()
    @State private var selectedTileType: TileTypeSelection = .factory  //track the current tile type to place
    @State private var isGameStarted = false  //track if the game has started
    
    //enum to manage tile selection
    enum TileTypeSelection {
        case factory
        case conveyorRight
        case conveyorLeft
        case conveyorUp
        case conveyorDown
        case miner
        case delete
    }
    //quit button
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: quitApp) {
                    Text("Quit")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
            }

            if isGameStarted {
                //show the main game UI after the game starts
                gameView
            } else {
                //show the start screen before the game begins
                StartScreen(isGameStarted: $isGameStarted)
            }
        }
    }
    
    var gameView: some View {
        VStack {
            //score display at the top
            Text("Score: \(gameState.maxScore)") //dsplay the score
                .font(.largeTitle)
                .bold()
                .padding()
            
            //game grid and buttons UI
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 1) {
                    ForEach(0..<gameState.grid.count, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0..<gameState.grid[row].count, id: \.self) { col in
                                TileView(tile: gameState.grid[row][col])
                                    .onTapGesture {
                                        //place a tile based on the selcted type
                                        placeTile(row: row, col: col)
                                    }
                            }
                        }
                    }
                }
            }
            .padding()
            
            //buttons for tile selection and actions
            tileSelectionButtons
            actionButtons
        }
    }
    
    var tileSelectionButtons: some View {
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
        }
        .padding()
    }
    
    var actionButtons: some View {
        HStack {
            Button(action: {
                gameState.toggleProcessing()
                print("Start Processing has been toggled")
            }) {
                Text(gameState.isProcessing ? "Stop Processing" : "Start Processing")
                    .padding()
                    .background(gameState.isProcessing ? Color.red : Color.green)
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
            
            Button(action: {
                selectedTileType = .delete
                print("Selected tile type: Delete")
            }) {
                Text("Delete")
                    .padding()
                    .background(selectedTileType == .delete ? Color.red.opacity(0.7) : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
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
        case .delete:
            gameState.removeTile(at: row, col: col)
        }
    }
    
    //function to reroll the grid to all empty tiles and regenerate resource clusters
    private func rerollGrid() {
        for row in 0..<gameState.grid.count {
            for col in 0..<gameState.grid[row].count {
                gameState.grid[row][col] = Tile(type: .empty, resourceCount: 0)
            }
        }
        gameState.spawnResourceClusters()
    }
    
    //function to quit the app
    func quitApp() {
        //using UIApplication.shared to quit the app
        gameState.reset()
        isGameStarted = false
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
}

