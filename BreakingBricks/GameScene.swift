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
    var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha) )
    return color
}


import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bgR = 0x00
    var bgG = 0x00
    var bgB = 0x00
    
    var targetColor = 0x444444
    
    func bgColor() -> Int {
        return  ((bgR & 0xff) << 16) + ((bgG & 0xff) << 8) + (bgB & 0xff)
    }
    
    func walkTargetToDestinationColor(destination: Int, step: Int){
        
        var targetR = (targetColor & 0xFF0000) >> 16
        var targetG = (targetColor & 0xFF00) >> 8
        var targetB = (targetColor & 0xFF)
        
        var destR = (destination & 0xFF0000) >> 16
        var destG = (destination & 0xFF00) >> 8
        var destB = (destination & 0xFF)
        
        // walk in the target red towards the destination red
        if ( targetR < destR ){
            if ( targetR + step <= 0xFF ){
                targetR += step
            } else {
                targetR = 0xFF
            }
        } else {
            if ( targetR - step >= 0x00 ){
                targetR -= step
            } else {
                targetR = 0x00
            }
        }
        
        // walk in the target green towards the destination green
        if ( targetG < destG ){
            if ( targetG + step <= 0xFF ){
                targetG += step
            } else {
                targetG = 0xFF
            }
        } else {
            if ( targetG - step >= 0x00 ){
                targetG -= step
            } else {
                targetG = 0x00
            }
        }
        
        // walk in the target blue towards the destination blue
        if ( targetB < destB ){
            if ( targetB + step <= 0xFF ){
                targetB += step
            } else {
                targetB = 0xFF
            }
        } else {
            if ( targetB - step >= 0x00 ){
                targetB -= step
            } else {
                targetB = 0x00
            }
        }
        
        self.targetColor =  ((targetR & 0xff) << 16) + ((targetG & 0xff) << 8) + (targetB & 0xff)
        
    }

    
    
    func fadeToTargetColor(target: Int, step: Int){
        // target is a hexdec Int
        // step represents the speed at which each RGB should progress
        
        var targetR = (target & 0xFF0000) >> 16
        var targetG = (target & 0xFF00) >> 8
        var targetB = (target & 0xFF)
        
        
        // walk in the background red towards the target
        if ( self.bgR < targetR ){
            if ( self.bgR + step <= 0xFF ){
                self.bgR += step
            } else {
                self.bgR = 0xFF
            }
        } else {
            if ( self.bgR - step >= 0x00 ){
                self.bgR -= step
            } else {
                self.bgR = 0x00
            }
        }
        
        // walk in the background green towards the target
        if ( self.bgG < targetG ){
            if ( self.bgG + step <= 0xFF ){
                self.bgG += step
            } else {
                self.bgG = 0xFF
            }
        } else {
            if ( self.bgG - step >= 0x00 ){
                self.bgG -= step
            } else {
                self.bgG = 0x00
            }
        }
        
        // walk in the background blue towards the target
        if ( self.bgB < targetB ){
            if ( self.bgB + step <= 0xFF ){
                self.bgB += step
            } else {
                self.bgB = 0xFF
            }
        } else {
            if ( self.bgB - step >= 0x00 ){
                self.bgB -= step
            } else {
                self.bgB = 0x00
            }
        }
        
        self.backgroundColor = colorize( bgColor(), alpha:1.0)
        
    }
    
    
    var paddle : SKSpriteNode
    var ball : SKSpriteNode
    //var ballVector :CGVector = CGVectorMake(9,-22)
    var playSFXBlip : SKAction = SKAction.playSoundFileNamed("blip.caf", waitForCompletion: false)
    var playSFXBrick : SKAction = SKAction.playSoundFileNamed("brickhit.caf", waitForCompletion: false)
    var label : SKLabelNode = SKLabelNode(fontNamed: "Futura Medium")
    //var staticSize : CGSize = CGSizeMake(0.0, 0.0)
   
    
    let AD = UIApplication.sharedApplication().delegate as AppDelegate
    
    
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

        //staticSize = CGSizeMake(size.width, size.height)
        
        // blue background color
        //self.backgroundColor = colorize( 0x003342, alpha:1.0)
        self.backgroundColor = colorize( bgColor(), alpha:1.0)
        
        
        //addBackground(size)
        
        AD.score = 0
        
        var labelNode = SKSpriteNode()
        
        label.text = "\(AD.score)"
        label.fontColor = SKColor.whiteColor()
        label.fontSize = 512
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-200)
        label.alpha = 0.05
        //label.physicsBody = SKPhysicsBody(rectangleOfSize: label.frame.size)
        
        labelNode.addChild(label)
        self.addChild(labelNode)
 
        
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
        var myPoint : CGPoint = CGPointMake(size.width/2, 120)
        ball.position = myPoint
        
        //var randomX = CGFloat( arc4random_uniform(20) - 10 )
        var ballVector : CGVector = CGVectorMake( 11, 15 )
        
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        
        ball.physicsBody.categoryBitMask = ballCategory
        ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory | bottomEdgeCategory
        
        ball.physicsBody.applyImpulse(ballVector)
        ball.physicsBody.friction = 0
        ball.physicsBody.linearDamping = 0
        ball.physicsBody.restitution = 1
        
        
        // an error here signifies a bad vector Y value in the negatives from the line 129 random call... needs a fix
    }
    
    func addLight (size:CGSize){
        
        // Load resources for iOS 8 or later
        var plasma : SKLightNode = SKLightNode()
        plasma.enabled = true
        
        plasma.categoryBitMask = 1
        plasma.falloff = 0.5
        plasma.ambientColor = colorize( 0xFFFFFF, alpha:0.5)
        plasma.lightColor = SKColor.whiteColor()
        plasma.position = CGPointMake(size.width/2,size.height+500)
        
        self.addChild(plasma)
        
        //ball.shadowedBitMask = 1
        //ball.shadowCastBitMask = 1
        ball.lightingBitMask = 1
        
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
                
                bg.position = CGPointMake(CGFloat(xPos), CGFloat(yPos))

            }
        }
        
    }
    
    
    
    func addBricks (size: CGSize){
        
        //println(" the input parameter size: \(size)")
        
        var maxRows = 3
        var maxCols = 6
        var xPos : CGFloat
        var yPos : CGFloat
        
        for (var rows = 0; rows < maxRows; rows++){
            for (var i = 0; i < maxCols ; i++){
                
                var brick: SKSpriteNode = SKSpriteNode(imageNamed: "brick")
                
                brick.name = String(AD.score)
                
                xPos = CGFloat(size.width) / CGFloat(maxCols+1) * CGFloat(i + 1)
                yPos = CGFloat(size.height) - CGFloat(80 * rows) - 50.0
                var newPoint = CGPointMake(xPos, yPos)
                brick.position = newPoint
                  
                brick.shadowCastBitMask = 1
                brick.lightingBitMask = 1
        
                self.addChild(brick)
        
                brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                brick.physicsBody.dynamic = false
                brick.physicsBody.categoryBitMask = brickCategory
        
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
            
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        // add a fade to color implementation
        fadeToTargetColor(self.targetColor, step:1)
        
        
        // level back fades
        if ( AD.score == 18 ){
            self.targetColor = 0x334400
        } else if ( AD.score == 22 ){
            self.targetColor = 0x337788
        }

        
        
        // each update fade the color
        fadeToTargetColor(self.targetColor, step: 1)
        
        
    }
    
    
    func incrementalSpeedAdjustment(rate: CGFloat){
        
        // multiplies the angular velocity of the ball by the chosen rate, both x and y axes
        
        self.ball.physicsBody.velocity.dx = self.ball.physicsBody.velocity.dx * rate
        self.ball.physicsBody.velocity.dy = self.ball.physicsBody.velocity.dy * rate
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact!){
        
        var notTheBall : SKPhysicsBody
        
        println( " dX: \(self.ball.physicsBody.velocity.dx) , dY: \(self.ball.physicsBody.velocity.dy)")
        
        // check the contacts and find the one thats not the ball
        if ( contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ){
            notTheBall = contact.bodyB
        } else {
            notTheBall = contact.bodyA
        }
        
        if ( notTheBall.categoryBitMask == brickCategory ) {
           
            // remove the brick
            AD.score++
            label.text = "\(AD.score)"
            
            notTheBall.node.removeFromParent()
            self.runAction(playSFXBrick)
            

            walkTargetToDestinationColor(0xAA0000, step:5)
            incrementalSpeedAdjustment(1.02)
            
        }
        
        
        if ( notTheBall.categoryBitMask == edgeCategory ) {
            /* edge contact logic... */
            walkTargetToDestinationColor(0x0099CC, step:33)
        
        }
        
        
        if ( notTheBall.categoryBitMask == bottomEdgeCategory ){
            
            var end : EndScene = EndScene.sceneWithSize(size)
            self.view.presentScene(end, transition: SKTransition.doorsCloseHorizontalWithDuration(0.5))
            
        }

        
        if ( notTheBall.categoryBitMask == paddleCategory ){
            
            self.runAction(playSFXBlip)
            
            if ( self.children.count <= 5 ){
                addBricks(self.frame.size)
            }
            
            walkTargetToDestinationColor(0x0099CC, step:3)
            incrementalSpeedAdjustment(1.02)

        }
        
    }
    
    
}