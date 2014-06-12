//
//  EndScene.swift
//  BreakingBricks
//
//  Created by Joseph Janiga on 6/11/14.
//  Copyright (c) 2014 Joseph Janiga. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
    
    var playSFXGameOver : SKAction = SKAction.playSoundFileNamed("gameover.caf", waitForCompletion: false)
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init (size: CGSize) {
        super.init(size: size)
    }
    
    // this gets triggered automtically when the scene is presented by the view
    // similar to Event.ADDED_TO_STAGE
    override func didMoveToView(view: SKView) {
        
        self.runAction(playSFXGameOver)
        
        // background color
        self.backgroundColor = colorize( 0x000000, alpha:1.0)
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "Futura Medium")
        label.text = "GAME OVER BRO"
        label.fontColor = SKColor.whiteColor()
        label.fontSize = 50
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))

        self.addChild(label)
        
        
        var label2 : SKLabelNode = SKLabelNode(fontNamed: "Futura Medium")
        label2.text = "touch to try again"
        label2.fontColor = SKColor.whiteColor()
        label2.fontSize = 33
        label2.position = CGPointMake(CGRectGetMidX(self.frame), -100)
        
        var moveLabel: SKAction = SKAction.moveToY(size.height/2-50, duration: 2.0)
        label2.runAction(moveLabel)
        
        self.addChild(label2)
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        /* Called when a touch begins */
        
        var start : GameScene = GameScene.sceneWithSize(size)
        self.view.presentScene(start, transition: SKTransition.doorsOpenHorizontalWithDuration(0.5))
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}