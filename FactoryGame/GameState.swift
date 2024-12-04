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
    
    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty), (.factory, .factory), (.resource, .resource), (.processed, .processed):
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
    var resourceCount: Int = 0  //track resources on this tile
    var processedCount: Int = 0 //track number of resources processed (for factories)
    
    func canAcceptResource() -> Bool {
        switch type {
        case .conveyor, .factory:
            return true
        default:
            return false
        }
    }
}

//game state that will manage the grid and gameplay logic
class GameState: ObservableObject {
    @Published var grid: [[Tile]]
    let gridSize: Int
    
    init(gridSize: Int = 7) {
        self.gridSize = gridSize
        self.grid = Array(repeating: Array(repeating: Tile(type: .empty), count: gridSize), count: gridSize)
        spawnResourceClusters()  // Spawn resource clusters when the game initializes
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
    
    //function to start processing: move resources and process factories
    func startProcessing() {
        moveResources()
        processFactories()
    }
    
    //function to move resources along conveyors
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
                
                if case .resource = tile.type, tile.resourceCount == 0 {
                    newGrid[row][col].resourceCount = 1
                }
            }
        }
        
        grid = newGrid
    }
    
    //function to process factories: convert resources into processed items
    private func processFactories() {
        var newGrid = grid
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let tile = grid[row][col]
                
                if tile.type == .factory, tile.resourceCount > 0 {
                    newGrid[row][col].resourceCount -= 1
                    newGrid[row][col].processedCount += 1  //increment processed count
                    newGrid[row][col].type = .processed
                }
                
                if tile.type == .processed {
                    newGrid[row][col].type = .factory
                }
            }
        }
        
        grid = newGrid
    }
    
    //function to spawn random resource clusters on the grid
    func spawnResourceClusters() {
        let clusterCount = Int.random(in: 3...5)  //randomly choose 3 to 5 clusters
        for _ in 0..<clusterCount {
            let clusterSize = Int.random(in: 3...5)  //each cluster has 3 to 5 tiles
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
}
