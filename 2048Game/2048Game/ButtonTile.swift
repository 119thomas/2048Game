//
//  ButtonTile.swift
//  assign3
//
//  Created by William Thomas on 3/1/19.
//

import UIKit

class ButtonTile: UIButton {
    var tile: Tile
    
    init(tile t: Tile) {
        self.tile = t
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
