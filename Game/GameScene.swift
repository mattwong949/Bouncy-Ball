//
//  GameScene.swift
//  Game
//
//  Created by Matthew Wong on 1/14/16.
//  Copyright (c) 2016 Matthew Wong. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
    var gameoverLabel = SKLabelNode()
    
    var face = SKSpriteNode()
    
    var background = SKSpriteNode()
    
    var wall1 = SKSpriteNode()
    var wall2 = SKSpriteNode()
    
    var movingObjects = SKSpriteNode()
    
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        
        case Face = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    func makeBackground()
    {
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size.height = self.frame.height
        
        let movebackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        let replacebackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        let movebackgroundforever = SKAction.repeatActionForever(SKAction.sequence([movebackground, replacebackground]))
        background.runAction(movebackgroundforever)
        
        for var i: CGFloat = 0; i < 3; i++ {
            background = SKSpriteNode(texture: backgroundTexture)
            
            background.position = CGPoint(x: backgroundTexture.size().width/2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            
            background.size.height = self.frame.height
            
            background.zPosition = 1
            
            background.runAction(movebackgroundforever)
            
            movingObjects.addChild(background)
        }
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        
        // BACKGROUND
        
        makeBackground()
        
        
        // Score
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 5
        labelContainer.addChild(scoreLabel)
        
        
        // Face
        
        let faceTexture = SKTexture(imageNamed: "face1.png")
        
        face = SKSpriteNode(texture: faceTexture)
        face.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        face.zPosition = 4
        
        face.physicsBody = SKPhysicsBody(circleOfRadius: faceTexture.size().height/2);
        face.physicsBody!.dynamic = true
        face.physicsBody!.allowsRotation = true
        
        face.physicsBody!.categoryBitMask = ColliderType.Face.rawValue
        face.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        face.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(face)
        
        
        // GROUND
        
        let ground = SKNode()
        ground.position = CGPointMake(0,0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        
        // WALLS
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makeWalls"), userInfo: nil, repeats: true)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
        {
            score++
            scoreLabel.text = String(score)
        }
        else
        {
            if gameOver == false
            {
                gameOver = true
        
                self.speed = 0
            
                gameoverLabel.fontName = "Helvetica"
                gameoverLabel.fontSize = 30
                gameoverLabel.text = "Game Over! Tap to play again!"
                gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameoverLabel.zPosition = 5
                labelContainer.addChild(gameoverLabel)
            }
        }
    }
    
    func makeWalls() {
        
        let gapHeight = face.size.height * 4
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let wallOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        let moveWalls = SKAction.moveByX(-self.frame.size.width*2, y: 0, duration: NSTimeInterval(self.frame.size.width) / 100)
        let removeWalls = SKAction.removeFromParent()
        let moveAndRemovewalls = SKAction.sequence([moveWalls, removeWalls])
        
        let wall1Texture = SKTexture(imageNamed: "wall.png")
        let wall1 = SKSpriteNode(texture: wall1Texture)
        wall1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + wall1Texture.size().height/2 + gapHeight/2 + wallOffset)
        wall1.zPosition = 2
        wall1.runAction(moveAndRemovewalls)
        
        wall1.physicsBody = SKPhysicsBody(rectangleOfSize: wall1Texture.size())
        wall1.physicsBody!.dynamic = false
        
        wall1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        wall1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        wall1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(wall1)
        
        let wall2Texture = SKTexture(imageNamed: "wall.png")
        let wall2 = SKSpriteNode(texture: wall2Texture)
        wall2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - wall2Texture.size().height/2 - gapHeight/2 + wallOffset)
        wall2.zPosition = 3
        wall2.runAction(moveAndRemovewalls)
        
        wall2.physicsBody = SKPhysicsBody(rectangleOfSize: wall1Texture.size())
        wall2.physicsBody!.dynamic = false
        
        wall2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        wall2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        wall2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(wall2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + wallOffset)
        gap.runAction(moveAndRemovewalls)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(wall1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false;
        
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Face.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameOver == false {
            face.physicsBody!.velocity = CGVectorMake(0, 0)
            face.physicsBody!.angularVelocity = CGFloat(1)
            face.physicsBody!.applyImpulse(CGVectorMake(0, 50))
        }
        else
        {
            score = 0
            
            scoreLabel.text = "0"
            
            face.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            
            face.physicsBody!.velocity = CGVectorMake(0, 0)
            
            movingObjects.removeAllChildren()
            
            makeBackground()
            
            self.speed = 1
            
            gameOver = false
            
            gameoverLabel.removeFromParent()
        }
    
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
