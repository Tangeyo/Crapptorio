# **Crapptorio**

Crapptorio is a simulation game where the players goal is to mine, transport and process raw resources into refined goods! On a 2D grid, players are able to place tiles such as factories, miners or conveyors to move, transport, and process resources in the most efficient way. The goal is to maximize the rate of output of processed goods and convert them into more (betterer) sophisticated goods!

## Initial Proposal

### Must have Requirements
- Playable grid area for placing tiles.
- Conveyors that move resources.
- Factories to process resources.
- Clusters of Ore.
- A processing button to start "timing".

### Nice to have Requirements
- Miners that bridge the gap between conveyor and ore.
- Automated Processing.
- Randomly generated clusters.
- Levels.
- Directional Conveyors.
- Various buildings, e.g. Smelters, Constructors, Oil pumps.

### Wireframe Version 01
<img src="https://github.com/Tangeyo/Crapptorio/raw/main/Wireframes/Wireframe01.png" alt="Example Image" width="400" height="750"/>

### Wireframe Version 02
<img src="https://github.com/Tangeyo/Crapptorio/raw/main/Wireframes/Wireframe02.png" alt="Example Image" width="400" height="750"/>


## Features

### Gameplay

- **Grid**: A 7x7 grid on which a player can place various tile types.

- **Tile Types**:
    - 🏭 **Factory**: Processes mined resources into goods.
    - ⛏️ **Miner**: Mines resources off the grid, and pushes resources onto conveyors.
    - →  **Conveyor (Belt)**: Moves resources in a specific direction.
    - 🪨 **Resource**: A raw material that must be mined and processed with miners.
    - ⚙️ **Processing**: Resources as they are being processed in factories.

- **Resource Clusters**: Random Generation of Deposits of raw materials to be mined with `Reroll grid`.
- **Automation**: Recursive automated processing with `Start processing`.

## Run

1. Clone this repo.
2. Open the project up in Xcode.
3. Build and run selecting the latest iPhone model. (15 pro used for simulation)
4. Start placing tiles, manage resources, and enjoy the game!

## How to Play

1. **Start of Game**:
	- Opening the app brings the user to a grid where resource clusters have been randomly generated.
2. **Place Tiles**:
	- Choose a tile type among **Factory**, **Miner**, or **Conveyor Belts** by clicking one of the available buttons.
    - Touch a cell of the grid to lay down the currently selected tile.
3. **Resource Handling**
    - Put **Miners** atop **Resources** in order to collect.
    - Route **Resources** onto **Conveyors** heading towards **Factories**.
    - Process raw materials via **Factories** into goods.
4. **Automation of Processes:**
    - Click the `Start Processing` button to enable automatic resource transport and processing at factories.
5. **Reset the Grid** :
    - Click the `Reroll Grid` button to reset the grid and spawn new clusters of resources.

## Technical Implementation

### The Grid

**Grid Structure**:
- The grid is treated as a 2D array of `Tile` objects. Each `Tile` object contains its type, the number of resources it has, and counts of processed items to allow for dynamic updating and interaction with it during gameplay.

**Grid Rendering**:
- The 7x7 grid is displayed using `ScrollView` and `VStack/HStack`. This allows for both vertical and horizontal scrolling in case the grid grows larger in future levels.
This grid is dynamically generated from the `gameState.grid` array; each cell-a `TileView`-is rendered with its tile type and resource count.

### The Tiles

**TileType Enum**:
- The core behind the game's tile management system, defining all the different types of tiles and their behaviors (like conveyor directions, factory, resource, etc.).
  - The operator `==` has been overridden to enable the comparison of the tile types and, hence, exact tile replacements can be made; for example, turning ore nodes into miners (miners can only be placed on ore nodes).

**Tile Behaviors**:
- Each tile type has a type of unique/limited behavior associated with it, miners can only mine resources, conveyors can move resources in a certain direction, and factories that process resources into finished products.
    - Ex. Miners can only be placed on ore nodes.
      
**Tile Placement**:
- With taps on the tiles in the grid, players place different types of tiles.
	- The interaction is handled through `.onTapGesture` with a `TileView` struct listening to user input and changes to the game state.
- When a player selects `Reroll Grid`, there is a randomizing system that generates ore clusters on the tiles with different amounts of ore in each node.
	- The `spawnResourceClusters()` function generates 3 to 5 random clusters of resource tiles on the grid. Each resource tile gets a random quantity (1 to 3), and each subsequent tile in the cluster is placed adjacent to the previous one.

**Tile Struct**:
- Every Tile is representative of the cell in the grid having instances that include type, resource count, and processed count.
	 - It contains helper methods such as `canAcceptResource()` to determine if a certain type of tile can hold/ process resources. This helper method is used in various other functions such as the `moveResources()` function which is responsible for allowing conveyors to check the state of being adjacent to a miner and accept input in the given direction.
  	- The `UUID()` property ensures that every tile has a distinct identity even if its other properties are identical, making every tile independent. 

### The Other Functions

**Buttons and Buildings**:
- User may change the tile type to one of the following by the interactive buttons rendered in `HStack` that toggle the `selectedTileType` state and, by extent, allow the user to choose between factory, miner, and conveyors.
- Certain functions such as `placeFactory(at:col:)` or `placeConveyor(at:col:direction:)` place tiles dependent on the grid location which is (row, col) and checks `isValidPosition` using the `guard` statement. It then updates the tile and replaces said tile with the respective type `.factory or .conveyor, .miner` etc.
	- These functions are designed to be easily scalable, allowing for future building types to be added with little to no changes to the original logic. New buildings can simply introduce additional parameters or behaviors while reusing the existing structure and validation logic.

**State Management + Automation**:
- The `GameState` class is marked as `@ObservedObject` to ensure that any changes in either the grid or the processing state automatically update the UI in real-time.
- The game incorporates the use of a recursive function, `processAutomatically()`, which, once triggered, allows the movement and processing of resources at regular intervals. In this way, the game runs along even when there is no interference by the user.
    - Ex. If user hits `Start Processing` then it calls the recursive function.
---

## Todos

- Add score and levels for challenging the players.
- Pre-set Factories players need to move resources to.
- Start Screen + Win screen at no more ore completion.
- Expand tile types for more complex resource management like different types of factories, or resource types.
- Ore -> Miner -> Conveyor -> Furnace -> Conveyor -> Resource Processor
- Add a sandbox mode for free play where the player can be allowed to create their own grid.

---
