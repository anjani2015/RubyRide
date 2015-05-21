//
//  RubyRideMyScene.m
//  RubyRide
//
//  Created by Anjani Mittal on 9/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "RubyRideMyScene.h"
#import "EndRide.h"
#import "StarNode.h"
#import <CoreMotion/CoreMotion.h>
#import "RubyRideSummaryInstance.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory)
{
    CollisionCategoryPlayer   = 0x1 << 0,
    CollisionCategoryStar     = 0x1 << 1,
};

@implementation RubyRideMyScene
{
    NSTimeInterval lastTimeSceneRefreshed;
    
    // Layered Nodes
    SKNode *_backgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudeNode;
    
    // Tap to start Node
    SKSpriteNode *_tapToStart;
    
    // Player
    SKNode *_player;
    
    // Height at which level ends
    int _endLevelY;
    
    // Max y reached by player
    int _maxPlayerY;
    
    // Labels for score and stars
    SKLabelNode *_lblScore;
    SKLabelNode *_lblStars;
    
    // Motion manager for accelerometer
    CMMotionManager *_motionManager;
    
    // Acceleration value from accelerometer
    CGFloat _xAcceleration;
    
    //Game State
    BOOL isGameOver;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your background here */
        
        // Reset
        _maxPlayerY = 80;
        
        //Set the Player Initial score
        [[RubyRideSummaryInstance sharedInstance]setScore:0];
        [[RubyRideSummaryInstance sharedInstance]setStarPoints:0];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f,-2.0f);
        self.physicsWorld.contactDelegate = self;
        
        //Background
        _backgroundNode = [self buildBackground];
        [self addChild:_backgroundNode];
        
        // Foreground
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        //HUD
        _hudeNode = [SKNode node];
        [self addChild:_hudeNode];
        
        // Load the level
        NSString *levelPlist = [[NSBundle mainBundle] pathForResource: @"Level01" ofType: @"plist"];
        NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
        
        // Height at which the player ends the level
        _endLevelY = [levelData[@"EndY"] intValue];
        
        // Add the stars
        NSDictionary *stars = levelData[@"Stars"];
        NSDictionary *starPatterns = stars[@"Patterns"];
        NSArray *starPositions = stars[@"Positions"];
        for (NSDictionary *starPosition in starPositions) {
            CGFloat patternX = [starPosition[@"x"] floatValue];
            CGFloat patternY = [starPosition[@"y"] floatValue];
            NSString *pattern = starPosition[@"pattern"];
            
            //NSLog(@"end y position ---- %.0f",patternY);

            
            // Look up the pattern
            NSArray *starPattern = starPatterns[pattern];
            for (NSDictionary *starPoint in starPattern) {
                CGFloat x = [starPoint[@"x"] floatValue];
                CGFloat y = [starPoint[@"y"] floatValue];
                
                //NSLog(@"Internal y position ---- %.0f",patternY);
                
                StarType type = [starPoint[@"type"] intValue];
                
                StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:starNode];
            }
        }
        
        //Add Tap to start image
        SKTexture *tapStartTexture = [SKTexture textureWithImageNamed:@"TapToStart"];
        _tapToStart = [SKSpriteNode spriteNodeWithTexture:tapStartTexture];
        _tapToStart.position = CGPointMake(160.0f, 150.0f);
//        _tapToStart.size = CGSizeMake(55, 36);
        [_hudeNode addChild:_tapToStart];
        
        //Game Score Label
        _lblScore = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblScore.fontColor = [SKColor whiteColor];
        _lblScore.fontSize = 20.0f;
        _lblScore.position = CGPointMake(15, 20);
        _lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _lblScore.text = [NSString stringWithFormat:@"Score %d",[[RubyRideSummaryInstance sharedInstance]score]];
        [_hudeNode addChild:_lblScore];
        
        // Add the player
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
        
        // CoreMotion
        _motionManager = [[CMMotionManager alloc] init];
        // 1
        _motionManager.accelerometerUpdateInterval = 0.2;
        // 2
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 // 3
                                                 CMAcceleration acceleration = accelerometerData.acceleration;
                                                 // 4
                                                 _xAcceleration = (acceleration.x * 0.75) + (_xAcceleration * 0.25);
                                             }];

    }
    return self;
}

- (SKNode *) createPlayer
{
    SKNode *playerNode = [SKNode node];
    [playerNode setPosition:CGPointMake(160.0f, 50.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"teddy"];
    [playerNode addChild:sprite];
    
    // 1
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    // 2
    playerNode.physicsBody.dynamic = NO;
    // 3
    playerNode.physicsBody.allowsRotation = NO;
    // 4
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    
    // 1
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    // 2
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    // 3
    playerNode.physicsBody.collisionBitMask = 0;
    // 4
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar;
    
    return playerNode;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if (isGameOver)
        return;
    
    if (currentTime - lastTimeSceneRefreshed > 1) {
        
        lastTimeSceneRefreshed = currentTime;
        [self backgroundNodesRepositioning];
    }
    
    if ((int)_player.position.y > _maxPlayerY) {
        // 2
        [RubyRideSummaryInstance sharedInstance].score += (int)_player.position.y - _maxPlayerY;
        // 3
        _maxPlayerY = (int)_player.position.y;
    }
    
    [_foregroundNode enumerateChildNodesWithName:@"NODE_STAR" usingBlock:^(SKNode *node, BOOL *stop) {
        [((StarNode *)node) checkNodeRemoval:_player.position.y];
    }];
    
    // Calculate player y offset
    if (_player.position.y > 200.0f) {
        _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
    
    // 1
    // Check if we've finished the level
    if (_player.position.y > _endLevelY) {
        isGameOver = YES;
    }
    
    // 2
    // Check if we've fallen too far
    if (_player.position.y < (_maxPlayerY - 400)) {
        isGameOver = YES;

    }
    
    if (isGameOver)
    {
        [[_backgroundNode childNodeWithName:@"background"] removeActionForKey:@"movement"];
        [self endRide];
    }
}

#pragma mark - SKPhysicsContactDelegate
- (void) didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    BOOL updateHUD = NO;
    
    // 2
    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    // 3
    updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];
    
    // Update the HUD if necessary
    if (updateHUD) {
        // 4 TODO: Update HUD in Part 2
        [_lblStars setText:[NSString stringWithFormat:@"X %d", [RubyRideSummaryInstance sharedInstance].starPoints]];
        [_lblScore setText:[NSString stringWithFormat:@"Score %d", [RubyRideSummaryInstance sharedInstance].score]];
    }
}

- (void) didSimulatePhysics
{
    // 1
    // Set velocity based on x-axis acceleration
    _player.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, _player.physicsBody.velocity.dy);
    
    // 2
    // Check x bounds
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(340.0f, _player.position.y);
    }
    else if (_player.position.x > 340.0f) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
    return;
}


- (StarNode *) createStarAtPosition:(CGPoint)position ofType:(StarType)type
{
    // 1
    StarNode *node = [StarNode node];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    
    // 2
    [node setStarType:type];
    SKSpriteNode *sprite;
    if (type == STAR_SPECIAL) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    }
    [node addChild:sprite];
    
    // 3
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    // 4
    node.physicsBody.dynamic = NO;
    
    node.physicsBody.categoryBitMask = CollisionCategoryStar;
    node.physicsBody.collisionBitMask = 0;
    node.physicsBody.contactTestBitMask = 0;
    
    return node;
}


// This method will add 3 background nodes
- (SKNode *)buildBackground
{
    SKNode *bgNode = [SKNode node];
    
    float centerX = CGRectGetMidX(self.frame);
    SKSpriteNode *firstBackgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
    firstBackgroundNode.name = @"background";
    firstBackgroundNode.position = CGPointMake(centerX,
                                               self.size.height/2);
    [bgNode addChild:firstBackgroundNode];
    float previousYPosition = firstBackgroundNode.position.y;
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        backgroundNode.position = CGPointMake(centerX,
                                              previousYPosition + backgroundNode.frame.size.height);
        previousYPosition = backgroundNode.position.y;
        backgroundNode.name = @"background";
        [bgNode addChild:backgroundNode];
    }
    return bgNode;
}


- (void)backgroundNodesRepositioning
{
    [_backgroundNode enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode *backgroundNode = (SKSpriteNode *)node;
         if (backgroundNode.position.y + backgroundNode.size.height < 0) {
             // The node is out of screen, move it up
             backgroundNode.position = CGPointMake(backgroundNode.position.x, backgroundNode.position.y + backgroundNode.size.height * 3);
         }
     }];
}

- (void)startScrolling
{
    [_backgroundNode enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         [node runAction:[SKAction repeatActionForever:[SKAction moveByX:0 y:-200 duration:1]] withKey:@"movement"];
     }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1
    // If we're already playing, ignore touches
    if (_player.physicsBody.dynamic) return;
    
    // 2
    // Remove the Tap to Start node
    [_tapToStart removeFromParent];
    
    // 3
    // Start the player by putting them into the physics simulation
    _player.physicsBody.dynamic = YES;
    
    // 4
    [_player.physicsBody applyImpulse:CGVectorMake(0.0f, 50.0f)];
    
    //5 Start scrolling the Background
    [self startScrolling];
}

- (void) endRide
{
    SKScene *endRideScene = [[EndRide alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition doorsCloseHorizontalWithDuration:0.5];
    reveal.pausesOutgoingScene = NO;
    [self.view presentScene:endRideScene transition:reveal];
}




@end
