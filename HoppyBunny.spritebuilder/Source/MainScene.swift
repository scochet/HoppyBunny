import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    var points : NSInteger = 0
    weak var scoreLabel : CCLabelTTF!
    
    weak var restartButton : CCButton!
    var gameOver = false
    
    // this is to reference the bunny, completing the code connection (named "hero")
    // started in SpriteBuilder
    weak var hero: CCSprite!
    
    weak var gamePhysicsNode: CCPhysicsNode!
    
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    var grounds = [CCSprite]() // initializes an empty array
    /* The array is initialized when declared by simply assigning it an empty array. This avoids having to implement the init function.
*/
    
    /* On touch, turn the bunny upwards
    If no touch occurred for a while, turn the bunny downwards
    Limit the rotation between slightly up and 90 degrees down (just like Flappy Bird)
    
    The first step is to add a property to keep track of the time since the last touch.
*/
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    
    // aggiungiamo degli ostacoli random
    var obstacles : [CCNode] = []
    let firstObstaclePosition : CGFloat = 280       // posizione X del primo ostacolo
    let distanceBetweenObstacles : CGFloat = 160    // distanza tra gli ostacoli
    
    // aggiungiamo il layer degli ostacoli
    weak var obstaclesLayer : CCNode!
    
    
    
    
    
    
    // here, we enable touch events;
    // didLoadFromCCB() is called every time a CCB file is loaded
    func didLoadFromCCB() {
        
        // assign MainScene ("self") as the collision delegate class;
        // this way, we can implement a collision handler method (ccPhysicsCollisionBegin)
        gamePhysicsNode.collisionDelegate = self
        
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)
        
        for _ in 0...2 {
            spawnNewObstacle()
        }
    }
    
    // this applies an impulse to the bunny every time a touch is first detected.
    // override: mind the idea of inheritance. MainScene is a child of CCNode, 
    // and CCNode has a touchBegan class we need to override, because MainScene
    // inherits the same touchBegan.
/*
    Next, extend the touch method to trigger the upward rotation on a touch. You implement this by applying an angular impulse to the physics body. You also need to reset the sinceTouch value every time a touch occurs:
    */
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            hero.physicsBody.applyImpulse(ccp(0, 400))
            hero.physicsBody.applyAngularImpulse(10000)
            sinceTouch = 0
        }
    }
    
    override func update(delta: CCTime) {
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        // limitiamo la rotazione del bunny; l'impulso angolare, altrimenti, lo fa ruotare troppo
        // how much time has passed since the last touch?
        sinceTouch += delta
        // now we limit the rotation of the bunny
        hero.rotation = clampf(hero.rotation, -30, 90)
        /*
        Next, you check if the bunny allows rotation because later, you will disable rotation upon death. If rotation is allowed, you clamp the angular velocity to slow down the rotation if it exceeds the value range. Then you apply that new angular velocity.
*/
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        /*
        Finally, you check if more than three tenths of a second passed since the last touch. If that is the case, a strong downward rotation impulse is applied.
*/
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        /*
        Clamping means testing and optionally changing a given value so that it never exceeds the specified value range.
        In this method, you are limiting the upwards velocity to 200 at most. By using the negative -Float(CGFloat.max) value as the minimum value, you avoid artificially limiting the falling speed. You don't need to set the x velocity because you will be setting the x position manually, so modifying the x velocity here would have no effect.
*/
        
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)

        // le righe seguenti sono state rimosse per un problema di arrotondamento:
        // le velocità risultanti di "hero" e "gamePhysicsNode" non coincidono!!!
        
        // let scale = CCDirector.sharedDirector().contentScaleFactor
        //hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
        //gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)

        hero.position = ccp((hero.position.x), (hero.position.y))
        gamePhysicsNode.position = ccp((gamePhysicsNode.position.x), (gamePhysicsNode.position.y))
        /* By multiplying the scroll speed with delta time you ensure that the bunny always moves at the same speed, independent of the frame rate.
        as a next step you should definitely set up some kind of "camera" that follows the bunny
*/
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            /* Since the ground sprites aren't children of the MainScene (self), you need to get the world position of the ground sprites first, then use the convertToNodeSpace method to convert the position in MainScene (self) coordinate space.
*/
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + (ground.contentSize.width * 2), ground.position.y)
            }
        }
        
        // check if an obstacle moved off the screen and if so, spawns a new obstacle in place of this one
        /*
        Note that we enumerate the obstacles array in reverse (backwards) so that we can legally remove and add objects at the end of the array while enumerating. More precisely: when enumerating an array in reverse, it is legal to modify the contents of the array at indexes equal to or higher than the index that's currently being processed. This is a neat trick to avoid having to fill a "to be deleted" array with another for loop that removes the items in the "to be deleted" list for good.
*/
        for obstacle in Array(obstacles.reverse()) {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(obstacles.indexOf(obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
    // il seguente method crea gli ostacoli
    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle /* declare the value returned and assigned to the 
                                                                    "obstacle" constant as being of class "Obstacle"
*/
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition() // call the setupRandomPosition() method from class "Obstacle" (change y position)
        obstaclesLayer.addChild(obstacle) // aggiungiamo l'ostacolo al layer degli ostacoli
        obstacles.append(obstacle)
    }
    
    // il method seguente verrà chiamato ogni volta che un object con collision type "hero" colliderà
    // con un object di collision type "level"
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        triggerGameOver()
        return true
    }
    
    // the "restart" method will be called when the restart button is pressed
    func restart() {
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    func triggerGameOver() {
        if (gameOver == false) {
            gameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            
            // just in case
            hero.stopAllActions()
            
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, goal: CCNode!) -> Bool {
        if (goal != nil) {
            goal.removeFromParent()
            points++
            scoreLabel.string = String(points)
        }
        return true
    }
        

}
