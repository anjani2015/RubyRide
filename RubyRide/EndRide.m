//
//  EndRide.m
//  RubyRide
//
//  Created by Anjani Mittal on 9/9/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "EndRide.h"
#import "RubyRideMyScene.h"
#import "RubyRideSummaryInstance.h"

@implementation EndRide

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [self setBackgroundColor:[SKColor darkGrayColor]];
        SKTexture *starTexture = [SKTexture textureWithImageNamed:@"Star"];
        
        //Stars
        SKSpriteNode *starNode = [SKSpriteNode spriteNodeWithTexture:starTexture];
        starNode.position = CGPointMake(120, self.size.height-60);
        [self addChild:starNode];
        
        //Stars Count Label
        SKLabelNode *countLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        countLabel.fontColor = [SKColor whiteColor];
        countLabel.fontSize = 25.0f;
        countLabel.position = CGPointMake(185, self.size.height-70);
        countLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        countLabel.text = [NSString stringWithFormat:@"X %d",[[RubyRideSummaryInstance sharedInstance]starPoints]];
        [self addChild:countLabel];
        
        //Game Score Label
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        scoreLabel.fontColor = [SKColor orangeColor];
        scoreLabel.fontSize = 55.0f;
        scoreLabel.position = CGPointMake(150, self.size.height-200);
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreLabel.text = @"Score";
        [self addChild:scoreLabel];
        
        //Game Points Label
        SKLabelNode *pointLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        pointLabel.fontColor = [SKColor greenColor];
        pointLabel.fontSize = 40.0f;
        pointLabel.position = CGPointMake(150, self.size.height-270);
        pointLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        pointLabel.text = [NSString stringWithFormat:@"%d",[[RubyRideSummaryInstance sharedInstance]score]];
        [self addChild:pointLabel];
        
        //Restart Game Label
        SKLabelNode *restartGameLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        restartGameLabel.fontColor = [SKColor whiteColor];
        restartGameLabel.fontSize = 15.0f;
        restartGameLabel.position = CGPointMake(160, self.size.height-400);
        restartGameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        restartGameLabel.text = @"Game Over Tap to start, Again!!";
        [self addChild:restartGameLabel];
        
    }
    
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Reset the Game score
    [[RubyRideSummaryInstance sharedInstance] setStarPoints:0];
    [[RubyRideSummaryInstance sharedInstance] setScore:0];
    
    // Transition back to the Game
    SKScene *rideScene = [[RubyRideMyScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
    [self.view presentScene:rideScene transition:reveal];
}


@end
