//
//  FriendGame.swift
//  Savas
//
//  Created by Dillon Murphy on 1/19/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

class FriendGame: GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RPSavvy"
        sideMenuObj.gameControls = true
        gameview.type = "friend"
    }
}
