//
//  board.swift
//  assign3
//
//  Created by William Thomas on 3/1/19.
//

import UIKit

class BoardView: UIView {
    private var colors = [
        UIColor(displayP3Red: 181/255, green: 173/255, blue: 161/255, alpha: 1),
        UIColor(displayP3Red: 226/255, green: 217/255, blue: 206/255, alpha: 1),
        UIColor(displayP3Red: 200/255, green: 184/255, blue: 166/255, alpha: 1),
        UIColor(displayP3Red: 237/255, green: 162/255, blue: 104/255, alpha: 1),
        UIColor(displayP3Red: 236/255, green: 143/255, blue: 85/255, alpha: 1),
        UIColor(displayP3Red: 241/255, green: 122/255, blue: 93/255, alpha: 1),
        UIColor(displayP3Red: 233/255, green: 89/255, blue: 55/255, alpha: 1),
        UIColor(displayP3Red: 242/255, green: 212/255, blue: 94/255, alpha: 1),
        UIColor(displayP3Red: 237/255, green: 198/255, blue: 8/255, alpha: 1),
        UIColor(displayP3Red: 250/255, green: 248/255, blue: 190/255, alpha: 1),
        UIColor(displayP3Red: 255/255, green: 255/255, blue: 26/255, alpha: 1),
        UIColor(displayP3Red: 230/255, green: 230/255, blue: 0/255, alpha: 1),
        UIColor(displayP3Red: 24/255, green: 23/255, blue: 20/255, alpha: 1)]
    
    /* we draw out our gameboard */
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let side = bounds.maxX / 4
        var xCoord = CGFloat(0), yCoord = CGFloat(0)
        
        // add 16 squares to the path
        for _ in 0...15 {
            path.append(UIBezierPath(rect: CGRect(x: xCoord, y: yCoord, width: side, height: side)))
            
            // update coordinates of said squares
            xCoord += side
            if(xCoord == CGFloat(bounds.maxX)) {
                yCoord += side
                xCoord = bounds.minX
            }
        }
        
        // draw all the squares; with thicc lines
        path.lineWidth = 7
        UIColor.gray.set()
        path.stroke()
    }
    
    /* super function */
    override func layoutSubviews() {
        layoutButtonTiles(bTiles: subviews.map {$0 as! ButtonTile})
    }
    
    /* we set the frames for each button tile that needs drawn/animated */
    func layoutButtonTiles(bTiles: [ButtonTile]) {
        let side = (bounds.maxX / 4)
        var isSpawn = true
        
        for button in bTiles {
            let xCoordTo = CGFloat(button.tile.col) * side
            let yCoordTo = CGFloat(button.tile.row) * side
            
            // fill the square with the proper color
            switch button.tile.value {
                case 0: button.backgroundColor = colors[0]
                case 2: button.backgroundColor = colors[1]
                case 4: button.backgroundColor = colors[2]
                case 8: button.backgroundColor = colors[3]
                case 16: button.backgroundColor = colors[4]
                case 32: button.backgroundColor = colors[5]
                case 64: button.backgroundColor = colors[6]
                case 128: button.backgroundColor = colors[7]
                case 256: button.backgroundColor = colors[8]
                case 512: button.backgroundColor = colors[9]
                case 1024: button.backgroundColor = colors[10]
                case 2048: button.backgroundColor = colors[11]
                default: button.backgroundColor = colors[12]
            }
            
            // draw the number
            let textColor = (button.tile.value >= 8) ? UIColor.white : UIColor.brown
            let textSize = (bounds.maxX / 4) / 2
            
//            let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 32.0)!,
//                               NSAttributedString.Key.foregroundColor: textColor]
//            let number = NSAttributedString(string: String(button.tile.value), attributes: myAttribute)
//            button.setAttributedTitle(number, for: .normal)
            button.setTitle(String(button.tile.value), for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont(name: "arial", size: textSize)
            
            if(button.tile.ident == -2) { // first 2 squares won't be animated
                button.frame = CGRect(x: xCoordTo, y: yCoordTo, width: side, height: side)
            }
            else if(isSpawn && button.tile.ident == -1) { // handle the initial spawn animation
                button.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    button.alpha = 1
                })
                isSpawn = false
                button.frame = CGRect(x: xCoordTo, y: yCoordTo, width: side, height: side)
            }
            else { // handle the movement animation otherwise; sliding / collapsing
                
                // create the frame for our current position
                let toHere = CGRect(x: xCoordTo, y: yCoordTo, width: side, height: side)
                let fromCol = (button.tile.ident - 1) % 4
                let fromRow = (button.tile.ident - 1) / 4
                
                // set our frame to where the tile was previously
                let xCoordFrom = CGFloat(fromCol) * side
                let yCoordFrom = CGFloat(fromRow) * side
                let fromHere = CGRect(x: xCoordFrom, y: yCoordFrom, width: side, height: side)
                button.frame = fromHere
        
                // transition tile to the new position with an animation
                UIView.transition(with: UIView(frame: fromHere), duration: 0.25, options: UIView.AnimationOptions.curveLinear, animations: {
                    button.frame = toHere
                }, completion: nil)
            }
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.gray.cgColor
        }
    }
}
