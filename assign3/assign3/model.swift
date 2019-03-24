//
//  model.swift
//  assign3
//
//  Created by William Thomas on 2/24/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import Foundation

/* Methods used to implement the 2048 game */
class game2048 {
    var gameBoard = [Tile]()
    private var deterministic = false
    var currScore = 0
    
    /* initializer for the class that handles deterministic effect
        and initializes the gameboard with 16 fresh tiles */
    init (repeatable : Bool) {
        // we will use pre seeded values if specified
        if(repeatable) {
            srand48(42)
            deterministic = true
        }
        
        // we will go ahead and set up the board with some fresh tiles
        var row = 0, col = 0
        while gameBoard.count != 16 {
            gameBoard.append(Tile(value: 0, row: row, col: col, ident: 0))
            col += 1
            if(col == 4) {
                row += 1; col = 0
            }
        }

        // new games always start with two spawns
        spawn()
        spawn()
        
        // we don't want these two tiles to be animated so we need
        // to set their identifiers as -2 so we can recognize them
        for tile in gameBoard {
            if(tile.ident == -1) {
                tile.ident = -2
            }
        }
    }
    
    /* this function takes an array of Tiles as its only parameter, and
        returns an optional array of Tiles. */
    private func collapse(arr : [Tile]) -> [Tile]? {
        var tmp: [Tile] = []
        
        if (arr.isEmpty) || (arr.count == 1) { return nil }
        
        // remove non zero Tiles
        for i in 0..<arr.count {
            if(arr[i].value != 0) {
                tmp.append(arr[i])
            }
        }
        
        // Search for the first pair of identical consecutive numbers
        // and set the ith value of them to x + x while i + 1 becomes 0
        if(tmp.count > 0) {
            for var i in 0..<tmp.count - 1 {
                if(tmp[i].value == tmp[i + 1].value) {
                    tmp[i].value += tmp[i].value
                    tmp[i].ident = tmp[i + 1].ident
                    currScore += tmp[i].value
                    tmp[i + 1].value = 0
                    i += 2
                }
            }
        }
        
        // search tmp for non zero values and append them to the newArray
        var newArr: [Tile] = []
        if(tmp.count > 0) {
            for i in 0..<tmp.count {
                if(tmp[i].value != 0) {
                    newArr.append(tmp[i])
                }
            }
        }
        
        // we will update row and col values in our game board
        var row = 0, col = 0;
        for tile in newArr {
            tile.row = row; tile.col = col; col += 1
            if(col == 4) {
                row += 1; col = 0
            }
        }
        
        // Append enough 0 tiles to newArray to make it the original length.
        while(newArr.count < arr.count) {
            let newTile = Tile(value: 0, row: row, col: col, ident: 0); col += 1
            if(col == 4) {
                row += 1; col = 0
            }
            newArr.append(newTile)
        }
        return (newArr != arr) ? newArr : nil;
    }
    
    /* returns true if there are no more possible moves.
        we do this by checking the value of adjacent tiles */
    func isDone() -> Bool {
        
        // first check for empty squares
        for tile in gameBoard {
            if(tile.value == 0) {
                return false
            }
        }
        
        // next we check for similar squares beside each other
        for i in 0...14 {
            if(i == 3 || i == 7 || i == 11 || i == 14) { continue }
            if(gameBoard[i].value == gameBoard[i + 1].value) {
                return false
            }
        }
        
        // finally we check for similar squares above and below each other
        for i in 0...11 {
            if(gameBoard[i].value == gameBoard[i + 4].value){
                return false
            }
        }
        return true
    }
    
    private func collapseTestBoard(testBoard: [Tile]) -> [Tile] {
        var begin = 0, end = 3
        var result = [Tile]()
        
        for _ in 0...3 {
            let currRow = testBoard[begin...end]
            let rowCollapsed = collapse(arr: Array(currRow))
            result += (rowCollapsed == nil) ? Array(currRow) : rowCollapsed!
            begin += 4 ; end += 4
        }
        return result
    }
    
    /* returns the current number of points */
    func score() -> Int {
        return currScore;
    }
    
    /* Creates a new minimum value (i.e. a '1', which will be display a
        s 2^1=2) in a randomly selected open tile */
    private func spawn() {
        var openCells = [Int]()
        
        // collect cells with open spots
        for i in 0..<gameBoard.count {
            if(gameBoard[i].value == 0) {
                openCells.append(i)
            }
        }
        
        // assign one of the open spots randomly
        if(!openCells.isEmpty) {
            let randomIndex = (deterministic) ?
                prng(max: openCells.count) : Int.random(in: 0 ... openCells.count - 1)
            
            
            gameBoard[openCells[randomIndex]].value = 2
            gameBoard[openCells[randomIndex]].ident = -1
            currScore += 2
        }
    }
    
    /* Directional movements */
    
    /* this helper function will collapse each row in the board */
    private func collapseBoard() {
        var begin = 0, end = 3, result = [Tile]()
        
        for _ in 0...3 {
            let currRow = gameBoard[begin...end]
            let rowCollapsed = collapse(arr: Array(currRow))
            result += (rowCollapsed == nil) ? Array(currRow) : rowCollapsed!
            begin += 4 ; end += 4
        }
        gameBoard = result
    }

    /* we need to keep the row and columns with the correct order; reset idents */
    private func updateRowCol() {
        var row = 0, col = 0
        
        for tile in gameBoard {
            tile.row = row; tile.col = col
            col += 1
            if(col == 4) {
                row += 1; col = 0;
            }
        }
    }
    
    /* we need to set our idents before we collapse the board */
    private func setIdentifiers() {
        var identifier = 1
        
        for tile in gameBoard {
            tile.ident = identifier
            identifier += 1
        }
    }
    
    /* compare two boards for equality (based on tile values) */
    private func compareBoards(board1: [Tile], board2: [Tile]) -> Bool{
        for i in 0..<board1.count {
            if(board1[i].value != board2[i].value) {
                return false
            }
        }
        return true
    }
    
    /* we make a deep copy of the board passed in */
    private func copyBoard(board: [Tile]) -> [Tile] {
        var copy = [Tile]()
        for tile in board {
            copy.append(Tile(value: tile.value, row: tile.row, col: tile.col, ident: tile.ident))
        }
        return copy
    }
    
    /* shift cells to the left, collapsing necissary rows */
    func left() {
        setIdentifiers()
        let initialBoard = copyBoard(board: gameBoard)
        collapseBoard()
        updateRowCol()
        
        // only update if the board has changed
        if(compareBoards(board1: initialBoard, board2: gameBoard) == false) {
            spawn()
        }
        updateRowCol()
    }
    
    /* shift cells to the right, collapsing necissary rows */
    func right() {
        setIdentifiers()
        let initialBoard = copyBoard(board: gameBoard)
        gameBoard.reverse1d2(size: 4)
        collapseBoard()
        gameBoard.reverse1d2(size: 4)
        updateRowCol()
        
        // only update if the board has changed
        if(compareBoards(board1: initialBoard, board2: gameBoard) == false) {
            spawn()
        }
        updateRowCol()
    }
    
    /* shift cells upward, collapsing necissary rows */
    func up() {
        setIdentifiers()
        let initialBoard = copyBoard(board: gameBoard)
        gameBoard.transpose1d2(size: 4)
        collapseBoard()
        gameBoard.transpose1d2(size: 4)
        
        // only update if the board has changed
        if(compareBoards(board1: initialBoard, board2: gameBoard) == false) {
            spawn()
        }
        updateRowCol()
    }
    
    /* shift cells downward, collapsing necissary rows */
    func down() {
        setIdentifiers()
        let initialBoard = copyBoard(board: gameBoard)
        gameBoard.transpose1d2(size: 4)
        gameBoard.reverse1d2(size: 4)
        collapseBoard()
        gameBoard.reverse1d2(size: 4)
        gameBoard.transpose1d2(size: 4)
        
        // only update if the board has changed
        if(compareBoards(board1: initialBoard, board2: gameBoard) == false) {
            spawn()
        }
        updateRowCol()
    }
    
    func getState() -> [Int] {
        var state = [Int]()
        for tile in gameBoard {
            state.append(tile.value)
        }
        return state
    }

    /* Random Generator */
    
    /* implements a pseudo random number generator (PRNG) that always generates
     the same sequence of values from the same initial seed. */
    func prng(max: Int) -> Int {
        return Int(floor(drand48() * (Double(max))))
    }
}

/* extension for the Array class; two new features:
    reverse1d2 && transpose1d2 */
extension Array {
    
    // This method will merely reverse each pseudo-row in-place.
    mutating func reverse1d2(size: Int) {
        var newArr: [Element] = []
        var curr = size - 1, prev = 0
        
        assert(self.count == (size * size))
        
        // loop through the subgroups
        for _ in 0..<size {
            
            // add sub-group to the array in reverse order starting
            // from the last element in the sub-group
            while(curr != (prev - 1)) {
                newArr.append(self[curr])
                curr -= 1
            }
            
            // switch to the next sub group and repeat
            prev = (curr + 1) + size
            curr = prev + (size - 1)
        }
        
        self = newArr
    }
    
    //This method does a full 2D transpose (in-place) of the Array
    mutating func transpose1d2(size: Int) {
        var newArr: [Element] = []
        
        assert(self.count == (size * size))
        
        // we traverse over 'size' amount of subgroups and
        // insert the ith value in each subgroup into the new array
        for j in 0..<size {
            for i in 0..<size {
                let increment = i * size
                newArr.append(self[increment + j])
            }
        }
        self = newArr
    }
}

/* represents a square in our gameboard;
     value - is the integer from assign2
     ident - is an identifier unique among all Tile instances of a single game
     row - vertical position in gameboard
     col - horizontal position in gameboard */
class Tile: Equatable {
    var value = 0, row = 0, col = 0, ident = 0

    init(value: Int, row: Int, col: Int, ident: Int) {
        self.value = value
        self.row = row
        self.col = col
        self.ident = ident
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.value == rhs.value &&
               lhs.row == rhs.row &&
               lhs.col == rhs.col &&
               lhs.ident == rhs.ident
    }
}
