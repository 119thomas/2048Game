//
//  ViewController.swift
//  assign3
//
//  Created by William Thomas on 2/24/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var gameBoard: BoardView!
    @IBOutlet weak var scoreDisplay: UILabel!
    var isDeterministic = false
    var game = game2048(repeatable: false)
    var highscoreController = HighController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add our gestures on load
        let left = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        
        let up = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        up.direction = .up
        self.view.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        down.direction = .down
        self.view.addGestureRecognizer(down)
        
        // initial game set-up
        updateBoard()
    }
    
    /* button actions */
    
    @IBAction func beginNewGame(_ sender: UIButton) {
        promptNewGame()
    }
    
    @IBAction func toggleDeterministic(_ sender: UISegmentedControl) {
        let alertController = UIAlertController(title: "New Game?", message:
            "All data will be lost.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in
            sender.selectedSegmentIndex = (sender.selectedSegmentIndex == 1) ? 0 : 1
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction) in
                self.isDeterministic = (sender.selectedSegmentIndex == 1) ?  true : false
                self.generateNewGame()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* functions */
    
    /* gestures */
    @objc func gestures(gesture: UISwipeGestureRecognizer) {
        if game.isDone() {
            gameOver()
        }
        else {
            switch gesture.direction {
                case .right: game.right();
                case .left: game.left();
                case .up: game.up();
                case .down: game.down();
                default: print("uhhhh")
            }
            updateBoard()
            gameBoard.setNeedsLayout()
        }
    }
    
    /* upate the board by adding and removing subviews from gameBoard */
    func updateBoard() {
        scoreDisplay.text = "\(game.score())"

        // we need to first clear our subviews
        for view in gameBoard.subviews {
            view.removeFromSuperview()
        }

        // next we will add the new subviews
        for tile in game.gameBoard {
            if(tile.value != 0) {
                let button = ButtonTile(tile: tile)
                gameBoard.addSubview(button)
            }
        }
    }
    
    /* prompt the user about starting a new game */
    func promptNewGame() {
        let alertController = UIAlertController(title: "New Game?", message:
            "All data will be lost.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction) in self.generateNewGame()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* generate the new game */
    func generateNewGame() {
        highscoreController.addScore(score: game.score())
        game = game2048(repeatable: isDeterministic)
        updateBoard()
        gameBoard.setNeedsLayout()
    }
    
    /* add high new high score; switch to highscores tab; reset the game */
    func gameOver() {
        highscoreController.addScore(score: game.score())
        self.tabBarController?.selectedIndex = 1
        let alertController = UIAlertController(title: "Game is Over!", message:
            "Your score: \(game.score())", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
            (action: UIAlertAction) in self.generateNewGame()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

