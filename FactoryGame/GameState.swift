import Foundation
import SwiftUI

//enum for conveyor direction
enum Direction: String {
    case up, down, left, right
    
    //helper to get an arrow symbol for the direction
    var arrow: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .left: return "←"
        case .right: return "→"
        }
    }
}

//enum to represent different types of tiles in the grid
enum TileType: Equatable {
    case empty
    case factory
    case conveyor(direction: Direction)
    case resource
    case processed
    case miner

    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty), (.factory, .factory), (.resource, .resource), (.processed, .processed), (.miner, .miner):
            return true
        case (.conveyor(let lhsDirection), .conveyor(let rhsDirection)):
            return lhsDirection == rhsDirection
        default:
            return false
        }
    }
}

//struct to represent each tile on the grid
struct Tile: Identifiable {
    let id = UUID()
    var type: TileType
    var resourceCount: Int = 0
    var processedCount: Int = 0

    func canAcceptResource() -> Bool {
        switch type {
        case .conveyor, .factory, .miner:
            return true
        default:
            return false
        }
    }
}


class GameState: ObservableObject {
    @Published var grid: [[Tile]]
    @Published var isProcessing: Bool = false
    let gridSize: Int
    
    //track score based on processed resources
    @Published var score: Int = 0
    @Published var maxScore: Int = 0 //track the highest score
    init(gridSize: Int = 7) {
        self.gridSize = gridSize
        self.grid = Array(repeating: Array(repeating: Tile(type: .empty), count: gridSize), count: gridSize)
        spawnResourceClusters()  //spawn resource clusters when the game initializes
    }
    
    //add a function to update the score
    private func updateScore() {
        score = 0
        //loop through the entire grid to sum up the processed counts
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let tile = grid[row][col]
                //if the tile is of type 'processed', add its processedCount to the score
                if case .processed = tile.type {
                    score += tile.processedCount
                }
            }
        }
        
        //update maxScore if the current score is higher to retain highest score on screen
        if score > maxScore {
            maxScore = score
        }
    }
    
    //function to place a factory on the grid
    func placeFactory(at row: Int, col: Int) {
        guard isValidPosition(row: row, col: col) else { return }
        grid[row][col] = Tile(type: .factory, resourceCount: grid[row][col].resourceCount)
    }
    
    //function to place a conveyor on the grid with a specific direction
    func placeConveyor(at row: Int, col: Int, direction: Direction) {
        guard isValidPosition(row: row, col: col) else { return }
        grid[row][col] = Tile(type: .conveyor(direction: direction), resourceCount: grid[row][col].resourceCount)
    }

    func placeMiner(at row: Int, col: Int) {
        guard isValidPosition(row: row, col: col), grid[row][col].type == .resource else { return }
        grid[row][col] = Tile(type: .miner, resourceCount: grid[row][col].resourceCount)
    }

    func toggleProcessing() {
        isProcessing.toggle()
        if isProcessing {
            processAutomatically()
        }
    }

    private func processAutomatically() {
        guard isProcessing else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moveResources()
            self.processFactories()
            self.processAutomatically()
        }
    }

    private func moveResources() {
        var newGrid = grid
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let tile = grid[row][col]
                
                if case let .conveyor(direction) = tile.type, tile.resourceCount > 0 {
                    let (nextRow, nextCol) = nextPosition(row: row, col: col, direction: direction)
                    
                    if isValidPosition(row: nextRow, col: nextCol) {
                        let nextTile = grid[nextRow][nextCol]
                        
                        if nextTile.canAcceptResource() {
                            newGrid[nextRow][nextCol].resourceCount += 1
                            newGrid[row][col].resourceCount -= 1
                        }
                    }
                }

                //handle miners
                if case .miner = tile.type, tile.resourceCount > 0 {
                    //miners push resources to adjacent conveyors in any direction
                    for direction in [Direction.up, Direction.down, Direction.left, Direction.right] {
                        let (nextRow, nextCol) = nextPosition(row: row, col: col, direction: direction)
                        if isValidPosition(row: nextRow, col: nextCol),
                           case .conveyor = grid[nextRow][nextCol].type {
                            newGrid[nextRow][nextCol].resourceCount += 1
                            newGrid[row][col].resourceCount -= 1
                            break //stop after moving one resource
                        }
                    }
                }
            }
        }
        
        grid = newGrid
    }
    
    //function to process factories: convert resources into processed items
    private func processFactories() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                var tile = grid[row][col]
                
                if tile.type == .factory, tile.resourceCount > 0 {
                    tile.resourceCount -= 1
                    tile.processedCount += 1
                    tile.type = .processed  //after processing, change the tile to 'processed'
                } else if tile.type == .processed {
                    //change processed tiles back to factory to allow processing again
                    tile.type = .factory
                }
                
                // Update the grid with the new tile state
                grid[row][col] = tile
            }
        }
        
        //now, after processing all factories, update the their score
        updateScore()
    }
    
    func resetGrid() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if case .factory = grid[row][col].type {
                    grid[row][col] = Tile(type: .empty)
                } else if case .conveyor = grid[row][col].type {
                    grid[row][col] = Tile(type: .empty)
                }
            }
        }
    }
    //spawn clusters for rerolls
    func spawnResourceClusters() {
        let clusterCount = Int.random(in: 3...5)
        for _ in 0..<clusterCount {
            let clusterSize = Int.random(in: 3...5)
            placeRandomCluster(of: clusterSize)
        }
    }
    
    //helper to place a single cluster of resources at a random location
    private func placeRandomCluster(of size: Int) {
        var row = Int.random(in: 0..<gridSize)
        var col = Int.random(in: 0..<gridSize)
        
        for _ in 0..<size {
            guard isValidPosition(row: row, col: col), grid[row][col].type == .empty else { continue }
            
            grid[row][col] = Tile(type: .resource, resourceCount: Int.random(in: 1...3))
            
            //randomly move to a nearby position for the next tile in the cluster
            let direction = [(-1, 0), (1, 0), (0, -1), (0, 1)].randomElement()!
            row += direction.0
            col += direction.1
        }
    }
    
    //helper function to get the next position based on direction
    private func nextPosition(row: Int, col: Int, direction: Direction) -> (Int, Int) {
        switch direction {
        case .up:
            return (row - 1, col)
        case .down:
            return (row + 1, col)
        case .left:
            return (row, col - 1)
        case .right:
            return (row, col + 1)
        }
    }
    
    //helper function to check if a position is within grid bounds
    private func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
    
    
    func removeTile(at row: Int, col: Int) {
        guard isValidPosition(row: row, col: col) else { return }

        //remove the tiles except for resources
        if case .resource = grid[row][col].type {
            return
        }

        //set the tile to empty
        grid[row][col] = Tile(type: .empty)
    }

    
    func reset() {
            //reset the score
            maxScore = 0
            
            //reset the processing state
            isProcessing = false
            
            //clear the grid, reset it to empty tiles
            for row in 0..<grid.count {
                for col in 0..<grid[row].count {
                    grid[row][col] = Tile(type: .empty, resourceCount: 0)
                }
            }
            //generate new resources
            spawnResourceClusters()
        }
}
