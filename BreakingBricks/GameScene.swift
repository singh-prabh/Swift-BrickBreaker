//
//  GameScene.swift
//  BreakingBricks
//
//  Created by Joseph Janiga on 6/8/14.
//  Copyright (c) 2014 Joseph Janiga. =]    All rights reserved.



import SpriteKit

class GameScene: SKScene {
    

    var paddle : SKSpriteNode
    
    init(coder aDecoder: NSCoder!) {

        paddle = SKSpriteNode(imageNamed:"paddle")
        super.init(coder: aDecoder)
    }
    
    
    init (size: CGSize) {
        self.paddle = SKSpriteNode(imageNamed:"paddle")
        super.init(size: size)
    }
    
    
    // this gets triggered automtically when the scene is presented by the view
    // similar to Event.ADDED_TO_STAGE
    override func didMoveToView(view: SKView) {
        
        // setup the world and background
        self.backgroundColor = SKColor.blackColor()
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.gravity = CGVectorMake(0,0)
        
        
        addBall(size)
        
        addPlayer(size)
        addBricks(size)
        
    }
    
    func addBall (size:CGSize){
        
        var ball : SKSpriteNode
        ball = SKSpriteNode(imageNamed: "ball")
        // setup and add the ball with physics
        var myPoint : CGPoint = CGPointMake(size.width/2, size.height/2+200)
        ball.position = myPoint
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        var ballVector :CGVector = CGVectorMake(11,-33)

        self.addChild(ball)
        ball.physicsBody.applyImpulse(ballVector)
        ball.physicsBody.friction = 0
        ball.physicsBody.linearDamping = 0
        ball.physicsBody.restitution = 1
        
    }
    
    func addPlayer (size:CGSize){
        
        paddle.position = CGPointMake(size.width/2, 100)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.frame.size)
        paddle.physicsBody.dynamic = false
        
        addChild(paddle)
    
    }
    
    func addBricks (size: CGSize){
        for (var rows = 0; rows < 5; rows++){
            for (var i = 0; i < 7 ; i++){
                var brick: SKSpriteNode = SKSpriteNode(imageNamed: "brick")
                brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                
                var xPos = size.width/8 * Float(i + 1)
                var yPos = size.height - Float(50 * rows) - 50
                
                brick.physicsBody.dynamic = false
                
                brick.position = CGPointMake(xPos, yPos)
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
    
}