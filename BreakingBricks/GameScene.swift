//
//  GameScene.swift
//  BreakingBricks
//
//  Created by Joseph Janiga on 6/8/14.
//  Copyright (c) 2014 Joseph Janiga. =]    All rights reserved.

import UIKit
import Foundation


// colorize function takes HEX and Alpha converts to UIColor object

func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    var color: UIColor = UIColor( red: Float(red), green: Float(green), blue: Float(blue), alpha:Float(alpha) )
    return color
}


import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var paddle : SKSpriteNode
    var ball : SKSpriteNode
    var ballVector :CGVector = CGVectorMake(9,-22)
    var playSFXBlip : SKAction = SKAction.playSoundFileNamed("blip.caf", waitForCompletion: false)
    var playSFXBrick : SKAction = SKAction.playSoundFileNamed("brickhit.caf", waitForCompletion: false)
    
    //bitwise
    let ballCategory : UInt32       = 0x1          // INT 1 - 00000000000000000000000000000001
    let brickCategory : UInt32      = 0x1 << 1     // INT 2 - 00000000000000000000000000000010
    let paddleCategory : UInt32     = 0x1 << 2     // INT 4 - 00000000000000000000000000000100
    let edgeCategory : UInt32       = 0x1 << 3     // INT 8 - 00000000000000000000000000001000
    let bottomEdgeCategory : UInt32 = 0x1 << 4     // INT 16- 00000000000000000000000000010000

    
    init(coder aDecoder: NSCoder!) {
        paddle = SKSpriteNode(imageNamed:"paddle")
        ball = SKSpriteNode(imageNamed: "ball")
        super.init(coder: aDecoder)
    }
    
    init (size: CGSize) {
        paddle = SKSpriteNode(imageNamed:"paddle")
        ball = SKSpriteNode(imageNamed: "ball")
        super.init(size: size)
    }
    
    
    func addBottomEdge(size:CGSize){
        
        var bottomEdge: SKNode = SKNode()
        bottomEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, 1), toPoint: CGPointMake(size.width, 1))
        bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory
        self.addChild(bottomEdge)
        
    }
    
    
    // this gets triggered automtically when the scene is presented by the view
    // similar to Event.ADDED_TO_STAGE
    override func didMoveToView(view: SKView) {

        // blue background color
        self.backgroundColor = colorize( 0x003342, alpha:1.0)
        
        //addBackground(size)
        

        
        
        // not sure if this effects performance yet...
        self.shouldRasterize = false
 
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody.categoryBitMask = edgeCategory
        
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        addBall(size)
        addPlayer(size)
        addBricks(size)
        addBottomEdge(size)
        addLight(size)
        
    }
    
    func addBall (size:CGSize){
        
        // setup and add the ball with physics
        var myPoint : CGPoint = CGPointMake(size.width/2, size.height-20)
        ball.position = myPoint
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        var ballVector :CGVector = CGVectorMake(9,-22)
        
        ball.physicsBody.categoryBitMask = ballCategory
        ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory | bottomEdgeCategory
        
        self.addChild(ball)
        ball.physicsBody.applyImpulse(ballVector)
        ball.physicsBody.friction = 0
        ball.physicsBody.linearDamping = 0
        ball.physicsBody.restitution = 1
        
        var magic :SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("Magic", ofType: "sks")) as SKEmitterNode
        
        magic.advanceSimulationTime(10)
        
        ball.addChild(magic)
        
        
    }
    
    func addLight (size:CGSize){
        
        // Load resources for iOS 8 or later
        var plasma : SKLightNode = SKLightNode()
        plasma.enabled = true
        
        plasma.categoryBitMask = 1
        plasma.falloff = 0.5
        plasma.ambientColor = colorize( 0xFFFFFF, alpha:0.5)
        plasma.lightColor = SKColor.whiteColor()
        plasma.position = CGPointMake(size.width/2,size.height-50)
        
        self.addChild(plasma)
        
        //ball.shadowedBitMask = 1
        //ball.shadowCastBitMask = 1
        //ball.lightingBitMask = 1
        
        paddle.shadowedBitMask = 1
        paddle.shadowCastBitMask = 1
        paddle.lightingBitMask = 1
        
    }
    
    func addPlayer (size:CGSize){
        
        paddle.position = CGPointMake(size.width/2, 100)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.frame.size)
        paddle.physicsBody.dynamic = false

        paddle.physicsBody.categoryBitMask = paddleCategory
        
        addChild(paddle)
    
    }
    
    
    func addBackground (size: CGSize){
        
        var h = 256
        var w = 256
        
        for (var cols = 0; cols < 3; cols++){
            for (var rows = 0; rows < 5; rows++){
                
                var xPos = Float(cols * h)
                var yPos = Float(rows * w)
                
                // setup the world and background
                var bg : SKSpriteNode
                var tex = SKTexture(imageNamed: "CorrugatedSharp-ColorMap" )
                bg = SKSpriteNode(texture: tex)
            

                bg.shadowedBitMask = 1
                bg.shadowCastBitMask = 1
                bg.lightingBitMask = 1

                
                bg.normalTexture = SKTexture(imageNamed: "CorrugatedSharp-ColorMap" ).textureByGeneratingNormalMap()
                self.addChild(bg)
                
                bg.position = CGPointMake(xPos, yPos)

            }
        }
        
    }
    
    
    
    func addBricks (size: CGSize){
        
        //println(" the input size \(size)")
        
        var maxRows = 2
        var maxCols = 6
        
        for (var rows = 0; rows < maxRows; rows++){
            for (var i = 0; i < maxCols ; i++){
                
                var brick: SKSpriteNode = SKSpriteNode(imageNamed: "brick")
                brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                
                var xPos = size.width/Float(maxCols+1) * Float(i + 1)
                var yPos = size.height - Float(80 * rows) - 100
                
                brick.physicsBody.dynamic = false
                brick.physicsBody.categoryBitMask = brickCategory
                  
                brick.shadowCastBitMask = 1
                brick.lightingBitMask = 1
                
                brick.position = CGPointMake(xPos, yPos)
                
                //println("\(brick.position)")
                
                self.addChild(brick)
            }
        }

    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent!) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            var location = touch.locationInNode(self)
            var new_pos = CGPointMake(location.x, 100)
            
            if (new_pos.x < self.paddle.size.width/2) {
                new_pos.x = self.paddle.size.width/2
            }
            if (new_pos.x > self.size.width - self.paddle.size.width/2){
                new_pos.x = self.size.width - self.paddle.size.width/2
            }
            
            self.paddle.position = new_pos
            
            //addBall(size)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact!){
        
        var notTheBall : SKPhysicsBody
        
        // check the contacts and find the one thats not the ball
        if ( contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ){
            notTheBall = contact.bodyB
        } else {
            notTheBall = contact.bodyA
        }
        
        if ( notTheBall.categoryBitMask == brickCategory ) {
            // remove the brick
            notTheBall.node.removeFromParent()
            self.runAction(playSFXBrick)
        }
        
        if ( notTheBall.categoryBitMask == edgeCategory ) {
            
        }
        
        if ( notTheBall.categoryBitMask == bottomEdgeCategory ){
            
            var end : EndScene = EndScene.sceneWithSize(size)
            self.view.presentScene(end, transition: SKTransition.doorsCloseHorizontalWithDuration(0.5))
            
        }

        
        if ( notTheBall.categoryBitMask == paddleCategory ){
            
            self.runAction(playSFXBlip)
            
            /*
            println("\(self.children.count) and \(self.frame.size)")
            
            if ( self.children.count <= 4 ){
                addBricks(self.frame.size)
            }
            */
            
        }
        
    }
    
    
}