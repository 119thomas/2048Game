//
//  highercontroller.swift
//  assign3
//
//  Created by William Thomas on 3/3/19.
//

import Foundation
import UIKit

class HighController: UIViewController {
    @IBOutlet weak var Leaderboards: UITextView!
    private var scores = [highScore]()
    
    private struct highScore: Codable {
        var score: Int
        var date: String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    /* update our view with the current leaderboard */
    func update() {
        var result = "", index = 1
        
        if let data = UserDefaults.standard.value(forKey: "scores") as? Data {
            let retrievedScores = try? PropertyListDecoder().decode(Array<highScore>.self, from: data)
            for score in retrievedScores! {
                result += "\(index)) \(score.score):\t\(score.date)\n"
                index += 1
            }
        }
        
        // set text and adjust font
        Leaderboards.text = result
        Leaderboards.adjustsFontForContentSizeCategory = true
        Leaderboards.textAlignment = .center
    }
    
    /* add a new high score to our leaderboard */
    // instead of adding to array, save to user deault
    func addScore(score: Int) {
    
        // get the current time and date (properly formatted)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy h:mm:ss"
        let formattedDate = formatter.string(from: NSDate() as Date)

        // retrieve previous high scores, create new high score; re-encode & save data
        let newHighScore = highScore(score: score, date: formattedDate)
        let retrievedScores = UserDefaults.standard.value(forKey: "scores") as? Data
        if(retrievedScores != nil) {
            var mutableScores = try? PropertyListDecoder().decode(Array<highScore>.self, from: retrievedScores!)
            mutableScores?.append(newHighScore)
            mutableScores?.sort(by: {$0.score > $1.score})
            UserDefaults.standard.set(try? PropertyListEncoder().encode(mutableScores), forKey:"scores")
        }
        else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode([newHighScore]), forKey:"scores")
        }
    }
}
